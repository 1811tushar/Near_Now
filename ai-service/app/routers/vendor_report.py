from fastapi import APIRouter, Depends

from app.schemas.ai import VendorReportRequest, VendorReportResponse
from app.services.vendor_report import VendorReportService
from app.core.auth import require_internal_api_key

router = APIRouter(prefix="/ai/vendor-report", tags=["vendor-report"])


@router.post("/summarize", response_model=VendorReportResponse, dependencies=[Depends(require_internal_api_key)])
def summarize_vendor_report(request: VendorReportRequest) -> VendorReportResponse:
    return VendorReportService().summarize(request)
