from fastapi import APIRouter, Depends

from app.core.auth import require_internal_api_key
from app.schemas.ai import DemandForecastRequest, DemandForecastResponse
from app.services.forecast import ForecastService

router = APIRouter(prefix="/ai/demand-forecast", tags=["demand-forecast"])


@router.post("/calculate", response_model=DemandForecastResponse, dependencies=[Depends(require_internal_api_key)])
def calculate_forecast(request: DemandForecastRequest) -> DemandForecastResponse:
    return ForecastService.calculate(request)
