from fastapi import APIRouter, Depends
from ..schemas.agentic import VendorReviewRequest, VendorReviewResponse
from ..services.vendor_review import review
from app.core.auth import require_internal_api_key

router = APIRouter(prefix="/ai/vendor-review", tags=["vendor-review"], dependencies=[Depends(require_internal_api_key)])

@router.post("/evaluate", response_model=VendorReviewResponse)
async def evaluate(req: VendorReviewRequest):
    return await review(req.model_dump())
