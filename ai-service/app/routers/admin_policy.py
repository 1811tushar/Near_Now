import json
import re

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, ValidationError

from app.core.auth import require_internal_api_key
from app.core.http_client import get_spring_boot_client
from app.schemas.rag import PolicyAnswerResponse, PolicyCitation, PolicyQuestionRequest
from app.services.gemini_service import GeminiService
from app.services.retrieval import RetrievalService


router = APIRouter(tags=["admin-policy"])


def _grounded(answer: str, chunks: list[dict]) -> bool:
    answer_terms = set(re.findall(r"[a-z]{4,}", answer.lower()))
    context_terms = set(re.findall(r"[a-z]{4,}", " ".join(chunk["content"] for chunk in chunks).lower()))
    return len(answer_terms & context_terms) >= 2


@router.post("/ai/admin/ask-policy", response_model=PolicyAnswerResponse, dependencies=[Depends(require_internal_api_key)])
async def ask_policy(request: PolicyQuestionRequest, client=Depends(get_spring_boot_client)) -> PolicyAnswerResponse:
    chunks = await RetrievalService(client).policy_chunks(request.question)
    if not chunks:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No relevant policy content found")

    context = [{"document_id": chunk["document_id"], "title": chunk["title"], "content": chunk["content"]} for chunk in chunks]
    prompt = f"""Answer the policy question using only the supplied policy excerpts.
Question: {request.question}
Excerpts: {json.dumps(context, ensure_ascii=False)}
Return JSON with exactly: answer (string) and citations (an array of one or more objects containing document_id and title).
If the excerpts do not answer the question, say that clearly; do not invent policy."""
    try:
        raw = await GeminiService().generate_json(prompt, _PolicyGeneration)
    except (ValidationError, ValueError) as error:
        raise HTTPException(status_code=502, detail="Gemini returned an invalid policy response") from error
    answer = PolicyAnswerResponse(answer=raw.answer, citations=raw.citations, grounded=_grounded(raw.answer, chunks))
    if not answer.grounded:
        answer.answer = "I could not produce a grounded answer from the retrieved policy excerpts."
    return answer


class _PolicyGeneration(BaseModel):
    answer: str
    citations: list[PolicyCitation]
