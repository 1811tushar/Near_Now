from pydantic import BaseModel, Field
from typing import List, Optional


class VendorWeeklyStats(BaseModel):
    vendor_id: int
    vendor_name: str
    week_start: str
    week_end: str
    orders_containing_vendor_products: int = 0
    orders_fulfilled: int = 0
    orders_cancelled: int = 0
    purchase_orders_created: int = 0
    purchase_orders_accepted: int = 0
    purchase_orders_dispatched: int = 0
    purchase_orders_received: int = 0
    purchase_orders_rejected: int = 0


class VendorReportRequest(BaseModel):
    stats: VendorWeeklyStats


class VendorReportResponse(BaseModel):
    summary: str


class VendorOnboardingFields(BaseModel):
    name: Optional[str] = None
    id_number: Optional[str] = None
    address: Optional[str] = None
    date_of_birth: Optional[str] = None
    document_type: Optional[str] = None
    issuing_authority: Optional[str] = None
    expiry_date: Optional[str] = None


class DemandPoint(BaseModel):
    date: str
    quantity: float = Field(ge=0)


class DemandSeries(BaseModel):
    store_id: int
    product_id: int
    current_stock: int = Field(ge=0)
    current_threshold: int = Field(ge=0)
    daily_demand: List[DemandPoint] = Field(default_factory=list)


class DemandForecastRequest(BaseModel):
    series: List[DemandSeries]
    method: str = "moving_average"
    window: int = Field(default=7, ge=1, le=90)


class ThresholdSuggestion(BaseModel):
    store_id: int
    product_id: int
    suggested_threshold: int = Field(ge=0)
    average_daily_demand: float = Field(ge=0)
    forecast_daily_demand: float = Field(ge=0)


class DemandForecastResponse(BaseModel):
    suggestions: List[ThresholdSuggestion]
