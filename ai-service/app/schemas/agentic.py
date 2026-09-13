from typing import Any, Literal
from pydantic import BaseModel, Field, ConfigDict


class AgentResponse(BaseModel):
    model_config = ConfigDict(extra="forbid")
    message: str
    requires_human_approval: bool = False
    proposed_action: str | None = None
    action_payload: dict[str, Any] | None = None
    evidence: list[str] = Field(default_factory=list)


class OrderSupportRequest(BaseModel):
    user_id: int
    session_id: str
    message: str


class OrderSupportResponse(AgentResponse):
    intent: Literal["order_status", "refund_eligibility", "cancel_proposal", "general"]


class FraudRequest(BaseModel):
    order_id: int
    trigger_reason: str | None = None


class FraudCase(BaseModel):
    model_config = ConfigDict(extra="forbid")
    order_id: int
    recommendation: Literal["CLEAR", "FLAG", "BLOCK"]
    confidence: float = Field(ge=0, le=1)
    reasoning: str
    evidence: list[str]
    requires_human_approval: bool = True


class VendorReviewRequest(BaseModel):
    vendor_id: int | None = None
    business_name: str
    business_address: str
    gst_number: str | None = None
    document_fields: dict[str, Any] | None = None


class VendorReviewResponse(BaseModel):
    recommendation: Literal["APPROVE", "ESCALATE", "REJECT"]
    confidence: float = Field(ge=0, le=1)
    reasoning: str
    evidence: list[str]
    requires_human_approval: bool
    business_rule_pass: bool


class ShoppingRequest(BaseModel):
    user_id: int
    session_id: str
    message: str


class ShoppingResponse(AgentResponse):
    products: list[dict[str, Any]] = Field(default_factory=list)
