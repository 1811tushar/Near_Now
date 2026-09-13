from langchain_core.tools import tool
from .spring_client import SpringClient

client = SpringClient()


@tool
async def search_products(query: str) -> list[dict]:
    """Search NearNow's existing product catalog using its semantic-search endpoint."""
    return await client.get("/api/products/semantic-search", {"q": query, "limit": 20})


@tool
def price_filter(products: list[dict], max_price: float) -> list[dict]:
    """Filter already-found products by effective price; does not mutate anything."""
    return [p for p in products if float(p.get("effectivePrice") or p.get("price") or 0) <= max_price]
