from fastapi import APIRouter, Depends

from app.core.auth import require_internal_api_key
from app.core.http_client import get_spring_boot_client
from app.schemas.rag import ProductIdsResponse, RecommendationRequest
from app.services.retrieval import RetrievalService


router = APIRouter(tags=["recommendations"])


@router.post("/ai/recommendations", response_model=ProductIdsResponse, dependencies=[Depends(require_internal_api_key)])
async def recommendations(request: RecommendationRequest, client=Depends(get_spring_boot_client)) -> ProductIdsResponse:
    ids = await RetrievalService(client).similar_product_ids(request.product_id, request.limit)
    return ProductIdsResponse(product_ids=ids)
