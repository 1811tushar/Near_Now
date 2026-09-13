from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

import httpx
from fastapi import Body, Depends, FastAPI

from app.core.auth import require_internal_api_key
from app.core.config import settings


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    """Own the shared client used only for calls back to Spring Boot."""
    app.state.spring_boot_client = httpx.AsyncClient(
        base_url=settings.spring_boot_base_url,
        timeout=settings.spring_boot_timeout_seconds,
    )
    yield
    await app.state.spring_boot_client.aclose()


app = FastAPI(title="NearNow AI Service", version="0.1.0", lifespan=lifespan)


@app.get("/health", tags=["system"])
async def health() -> dict[str, str]:
    """Unauthenticated liveness probe for Docker/orchestrators."""
    return {"status": "ok"}


@app.post("/ai/hello", tags=["example"], dependencies=[Depends(require_internal_api_key)])
async def hello(payload: dict = Body(...)) -> dict:
    """Authenticated wiring check; replace nothing here with feature logic."""
    return {"received": payload}


# Future feature routers are registered here, for example:
# from app.routers import recommendations
# app.include_router(recommendations.router, prefix="/ai", dependencies=[Depends(require_internal_api_key)])
from app.routers import product_description, review_summary
from app.routers import admin_policy, recommendations, search
from app.routers.vendor_report import router as vendor_report_router
from app.routers.vendor_onboarding_ocr import router as vendor_onboarding_ocr_router
from app.routers.demand_forecast import router as demand_forecast_router
from app.routers.order_support import router as order_support_router
from app.routers.shopping_assistant import router as shopping_router
from app.routers.fraud_investigation import router as fraud_router
from app.routers.vendor_review import router as vendor_review_router

app.include_router(product_description.router)
app.include_router(review_summary.router)
app.include_router(search.router)
app.include_router(recommendations.router)
app.include_router(admin_policy.router)
app.include_router(vendor_report_router)
app.include_router(vendor_onboarding_ocr_router)
app.include_router(demand_forecast_router)
app.include_router(order_support_router)
app.include_router(shopping_router)
app.include_router(fraud_router)
app.include_router(vendor_review_router)

