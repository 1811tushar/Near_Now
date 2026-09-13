from langchain_core.tools import tool
from .spring_client import SpringClient

client = SpringClient()


@tool
async def get_order_history(user_id: int) -> list[dict]:
    """Retrieve recent order history for cross-order anomaly investigation."""
    return await client.get(f"/api/internal/ai/users/{user_id}/orders")


@tool
async def get_vendor_history(vendor_id: int) -> dict:
    """Retrieve vendor product/order/purchase-order history for investigation."""
    return await client.get(f"/api/internal/ai/vendors/{vendor_id}/history")
