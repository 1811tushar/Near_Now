import asyncio
import os
from typing import TypeVar

from google import genai
from google.genai import types
from pydantic import BaseModel


ResponseModel = TypeVar("ResponseModel", bound=BaseModel)


class GeminiService:
    """Small structured-output wrapper; each request makes exactly one model call."""

    def __init__(self) -> None:
        api_key = os.getenv("GEMINI_API_KEY", "")
        if not api_key:
            raise RuntimeError("GEMINI_API_KEY must be set")
        self._client = genai.Client(api_key=api_key)
        self._model = os.getenv("GEMINI_MODEL", "gemini-2.5-flash")

    async def generate_json(
        self, prompt: str, response_model: type[ResponseModel]
    ) -> ResponseModel:
        response = await asyncio.to_thread(
            self._client.models.generate_content,
            model=self._model,
            contents=prompt,
            config=types.GenerateContentConfig(
                temperature=0.4,
                response_mime_type="application/json",
                response_schema=response_model,
            ),
        )
        # Validate the provider payload independently before returning it.
        return response_model.model_validate_json(response.text)
