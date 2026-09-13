from langchain_core.tools import tool
from .spring_client import SpringClient

client = SpringClient()


@tool
async def get_order_status(order_id: int, user_id: int) -> dict:
    """Look up the authenticated user's order by order id and return status/timestamps."""
    return await client.get(f"/api/internal/ai/orders/{order_id}?userId={user_id}")


@tool
async def check_refund_eligibility(order_id: int, user_id: int) -> dict:
    """Check refund eligibility without executing a refund."""
    return await client.get(f"/api/internal/ai/orders/{order_id}/refund-eligibility?userId={user_id}")
