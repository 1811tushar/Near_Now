"""Shared RAG retrieval. It deliberately accesses data only through Spring Boot."""

from collections import defaultdict

import httpx

from app.core.config import settings


class RetrievalService:
    RRF_K = 60

    def __init__(self, spring_boot_client: httpx.AsyncClient) -> None:
        self._client = spring_boot_client
        self._headers = {"X-Internal-API-Key": settings.internal_api_key}

    async def hybrid_product_ids(self, query: str, limit: int) -> list[int]:
        response = await self._client.post(
            "/api/internal/ai/retrieval/search-candidates",
            headers=self._headers,
            json={"query": query, "limit": limit},
        )
        response.raise_for_status()
        payload = response.json()
        return self._rrf_merge(
            payload.get("vector_product_ids", []),
            payload.get("keyword_product_ids", []),
            limit=limit,
        )

    async def similar_product_ids(self, product_id: int, limit: int) -> list[int]:
        response = await self._client.get(
            "/api/internal/ai/retrieval/similar-product-ids",
            headers=self._headers,
            params={"productId": product_id, "limit": limit},
        )
        response.raise_for_status()
        return [int(value) for value in response.json().get("product_ids", [])]

    async def policy_chunks(self, question: str, limit: int = 4) -> list[dict]:
        response = await self._client.get(
            "/api/internal/ai/retrieval/policy-chunks",
            headers=self._headers,
            params={"q": question, "limit": limit},
        )
        response.raise_for_status()
        return response.json().get("chunks", [])

    @classmethod
    def _rrf_merge(cls, *rankings: list[int], limit: int) -> list[int]:
        scores: dict[int, float] = defaultdict(float)
        for ranking in rankings:
            for rank, product_id in enumerate(ranking, start=1):
                scores[int(product_id)] += 1 / (cls.RRF_K + rank)
        return [product_id for product_id, _ in sorted(scores.items(), key=lambda item: (-item[1], item[0]))[:limit]]