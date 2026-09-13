from langchain_core.messages import HumanMessage
from .llm import llm

async def review(payload: dict) -> dict:
    rules = (
        "Business rule checks: business name/address are required; GST if supplied must be 15 chars; "
        "OCR fields must not materially conflict with registration fields. Recommend APPROVE only when "
        "evidence is clear, ESCALATE when ambiguous, REJECT when clear rule violations exist."
    )
    response = await llm().ainvoke([HumanMessage(content=(
        "Review this NearNow vendor onboarding record. " + rules + " Return JSON: recommendation, confidence, "
        "reasoning, evidence, requires_human_approval, business_rule_pass. Data=" + str(payload)
    ))])
    import json
    try:
        return json.loads(response.content)
    except Exception:
        return {"recommendation":"ESCALATE","confidence":0.0,"reasoning":response.content,"evidence":[],"requires_human_approval":True,"business_rule_pass":False}
