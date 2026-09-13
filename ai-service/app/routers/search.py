from fastapi import APIRouter, Depends

from app.core.auth import require_internal_api_key
from app.core.http_client import get_spring_boot_client
from app.schemas.rag import ProductIdsResponse, ProductSearchRequest
from app.services.retrieval import RetrievalService


router = APIRouter(tags=["rag-search"])


@router.post("/ai/search", response_model=ProductIdsResponse, dependencies=[Depends(require_internal_api_key)])
async def search_products(request: ProductSearchRequest, client=Depends(get_spring_boot_client)) -> ProductIdsResponse:
    ids = await RetrievalService(client).hybrid_product_ids(request.query.strip(), request.limit)
    return ProductIdsResponse(product_ids=ids)
