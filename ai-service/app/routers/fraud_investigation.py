from fastapi import APIRouter, Depends
from ..schemas.agentic import FraudRequest, FraudCase
from ..tools.spring_client import SpringClient
from ..services.fraud import run
from app.core.auth import require_internal_api_key

router = APIRouter(prefix="/ai/fraud", tags=["fraud"], dependencies=[Depends(require_internal_api_key)])

@router.post("/investigate", response_model=FraudCase)
async def investigate(req: FraudRequest):
    order = await SpringClient().get(f"/api/internal/ai/orders/{req.order_id}/investigation")
    result = await run(order)
    result["order_id"] = req.order_id
    result["requires_human_approval"] = True
    return result
