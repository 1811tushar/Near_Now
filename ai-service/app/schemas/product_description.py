from pydantic import BaseModel, Field, field_validator


class ProductDescriptionRequest(BaseModel):
    product_name: str = Field(min_length=1, max_length=200)
    category: str = Field(min_length=1, max_length=100)
    bullet_points: list[str] = Field(min_length=1, max_length=12)

    @field_validator("bullet_points")
    @classmethod
    def bullet_points_must_not_be_blank(cls, values: list[str]) -> list[str]:
        if any(not point.strip() for point in values):
            raise ValueError("bullet_points must not contain blank values")
        return values


class ProductDescriptionResponse(BaseModel):
    description: str = Field(min_length=1, max_length=2000)
