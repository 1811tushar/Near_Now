from fastapi import APIRouter, Depends
from ..schemas.agentic import OrderSupportRequest, OrderSupportResponse
from ..services.order_support import chat
from app.core.auth import require_internal_api_key

router = APIRouter(prefix="/ai/chat", tags=["order-support"], dependencies=[Depends(require_internal_api_key)])

@router.post("/order-support", response_model=OrderSupportResponse)
async def order_support(req: OrderSupportRequest):
    return await chat(req.user_id, req.session_id, req.message)
