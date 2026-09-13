import os

from google import genai
from google.genai import types

from app.schemas.ai import VendorReportRequest, VendorReportResponse


class VendorReportService:
    def __init__(self) -> None:
        api_key = os.getenv("GEMINI_API_KEY")
        if not api_key:
            raise RuntimeError("GEMINI_API_KEY is not configured")
        self.client = genai.Client(api_key=api_key)
        self.model = os.getenv("GEMINI_MODEL", "gemini-2.5-flash")

    def summarize(self, request: VendorReportRequest) -> VendorReportResponse:
        stats = request.stats
        prompt = f"""
Write one concise, professional paragraph for a weekly vendor performance report for NearNow.
Use ONLY the supplied numbers. Do not invent causes, ratings, percentages, or facts.
Mention fulfillment activity and purchase-order lifecycle activity. If a count is zero, state it only when useful.
Do not recommend or trigger any operational action.

Vendor: {stats.vendor_name}
Week: {stats.week_start} to {stats.week_end}
Orders containing vendor products: {stats.orders_containing_vendor_products}
Orders fulfilled (DELIVERED): {stats.orders_fulfilled}
Orders cancelled: {stats.orders_cancelled}
POs created: {stats.purchase_orders_created}
POs accepted: {stats.purchase_orders_accepted}
POs dispatched: {stats.purchase_orders_dispatched}
POs received: {stats.purchase_orders_received}
POs rejected: {stats.purchase_orders_rejected}
""".strip()

        response = self.client.models.generate_content(
            model=self.model,
            contents=prompt,
            config=types.GenerateContentConfig(
                temperature=0.2,
                max_output_tokens=220,
            ),
        )
        text = (response.text or "").strip()
        if not text:
            raise RuntimeError("Gemini returned an empty vendor report")
        return VendorReportResponse(summary=text)
