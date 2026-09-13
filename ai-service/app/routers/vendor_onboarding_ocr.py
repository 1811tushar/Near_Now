import io
import os

import pytesseract
from PIL import Image
from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from google import genai
from google.genai import types

from app.core.auth import require_internal_api_key
from app.schemas.ai import VendorOnboardingFields

router = APIRouter(prefix="/ai/vendor-onboarding", tags=["vendor-onboarding"])


@router.post(
    "/extract",
    response_model=VendorOnboardingFields,
    dependencies=[Depends(require_internal_api_key)],
)
def extract_vendor_onboarding_fields(file: UploadFile = File(...)) -> VendorOnboardingFields:
    content = file.file.read()
    if not content:
        raise HTTPException(status_code=400, detail="Uploaded document is empty")

    try:
        image = Image.open(io.BytesIO(content))
    except Exception as exc:
        raise HTTPException(status_code=400, detail="Uploaded file is not a readable image") from exc
    ocr_text = pytesseract.image_to_string(image).strip()
    if not ocr_text:
        return VendorOnboardingFields()

    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        raise RuntimeError("GEMINI_API_KEY is not configured")

    client = genai.Client(api_key=api_key)
    model = os.getenv("GEMINI_MODEL", "gemini-2.5-flash")
    prompt = f"""
Extract vendor onboarding fields from the OCR text below.
Return ONLY fields supported by the document. Never guess or infer missing values.
Normalize obvious whitespace only; preserve identifiers accurately.

OCR TEXT:
{ocr_text}
""".strip()

    response = client.models.generate_content(
        model=model,
        contents=prompt,
        config=types.GenerateContentConfig(
            temperature=0,
            response_mime_type="application/json",
            response_schema=VendorOnboardingFields,
        ),
    )
    return VendorOnboardingFields.model_validate_json(response.text or "{}")
