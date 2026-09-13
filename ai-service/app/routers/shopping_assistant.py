from fastapi import APIRouter, Depends
from ..schemas.agentic import ShoppingRequest, ShoppingResponse
from ..services.shopping import chat
from app.core.auth import require_internal_api_key

router = APIRouter(prefix="/ai/chat", tags=["shopping-assistant"], dependencies=[Depends(require_internal_api_key)])

@router.post("/shopping", response_model=ShoppingResponse)
async def shopping(req: ShoppingRequest):
    return await chat(req.user_id, req.session_id, req.message)
