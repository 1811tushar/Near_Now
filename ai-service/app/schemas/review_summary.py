from pydantic import BaseModel, Field, field_validator


class ReviewSummaryRequest(BaseModel):
    review_texts: list[str] = Field(min_length=1, max_length=100)

    @field_validator("review_texts")
    @classmethod
    def review_texts_must_not_be_blank(cls, values: list[str]) -> list[str]:
        if any(not review.strip() for review in values):
            raise ValueError("review_texts must not contain blank values")
        return values


class ReviewSummaryResponse(BaseModel):
    summary: str = Field(min_length=1, max_length=1500)
