from pydantic import BaseModel, Field


class ProductSearchRequest(BaseModel):
    query: str = Field(min_length=1, max_length=120)
    limit: int = Field(default=20, ge=1, le=50)


class ProductIdsResponse(BaseModel):
    product_ids: list[int]


class RecommendationRequest(BaseModel):
    product_id: int = Field(gt=0)
    limit: int = Field(default=10, ge=1, le=20)


class PolicyQuestionRequest(BaseModel):
    question: str = Field(min_length=3, max_length=1000)


class PolicyCitation(BaseModel):
    document_id: str
    title: str


class PolicyAnswerResponse(BaseModel):
    answer: str = Field(min_length=1)
    citations: list[PolicyCitation] = Field(min_length=1)
    grounded: bool
