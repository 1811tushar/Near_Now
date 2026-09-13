import os
from typing import Any
import httpx


class SpringClient:
    def __init__(self):
        self.base_url = os.getenv("SPRING_BOOT_BASE_URL", "http://backend:8080").rstrip("/")
        self.api_key = os.environ["INTERNAL_API_KEY"]

    async def get(self, path: str, params: dict[str, Any] | None = None) -> Any:
        async with httpx.AsyncClient(timeout=15) as client:
            r = await client.get(
                f"{self.base_url}{path}",
                params=params,
                headers={"X-Internal-API-Key": self.api_key},
            )
            r.raise_for_status()
            body = r.json()
            return body.get("data", body) if isinstance(body, dict) else body
