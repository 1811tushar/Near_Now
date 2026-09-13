from typing import TypedDict, Annotated
from langgraph.graph import StateGraph, END
from langchain_core.messages import HumanMessage, AIMessage, ToolMessage
from .llm import llm
from .memory import ConversationMemory
from ..tools.order_support import get_order_status, check_refund_eligibility
from ..schemas.agentic import OrderSupportResponse

class State(TypedDict):
    messages: Annotated[list, list.__add__]
    user_id: int

memory = ConversationMemory()

tools = {"get_order_status": get_order_status, "check_refund_eligibility": check_refund_eligibility}

async def agent(state: State):
    model = llm().bind_tools(list(tools.values()))
    instruction = HumanMessage(content=(
        "You are a NearNow order-support agent. Decide dynamically which read-only tool is useful. Current user id=" + str(state.get("user_id", "unknown")) + ". "
        "You may call order status and/or refund eligibility. Never execute cancellation or refund. "
        "If the user's request is cancellation, the correct next step is to propose cancellation and require "
        "human approval; do not invent a tool call."
    ))
    return {"messages": [await model.ainvoke([instruction, *state["messages"]])]}

async def tool_node(state: State):
    outputs = []
    for call in getattr(state["messages"][-1], "tool_calls", []):
        result = await tools[call["name"]].ainvoke(call["args"])
        outputs.append(ToolMessage(content=str(result), tool_call_id=call["id"]))
    return {"messages": outputs}

def route(state: State):
    return "tools" if getattr(state["messages"][-1], "tool_calls", []) else "final"

async def final_node(state: State):
    structured = llm().with_structured_output(OrderSupportResponse)
    response = await structured.ainvoke([HumanMessage(content=(
        "Produce the final support response from this conversation/evidence. Determine the intent yourself. "
        "Read-only intents require no approval. Cancellation requires_human_approval=true and proposed_action="
        "CANCEL_ORDER; never claim it was executed. Conversation/evidence=" + str(state["messages"]) ))])
    return {"messages": [AIMessage(content=response.model_dump_json())]}

g = StateGraph(State)
g.add_node("agent", agent)
g.add_node("tools", tool_node)
g.add_node("final", final_node)
g.set_entry_point("agent")
g.add_conditional_edges("agent", route, {"tools":"tools", "final":"final"})
g.add_edge("tools", "agent")
g.add_edge("final", END)
graph = g.compile()

async def chat(user_id: int, session_id: str, text: str) -> dict:
    history = await memory.load(session_id)
    msgs = [HumanMessage(content=x["content"]) if x["role"] == "user" else AIMessage(content=x["content"]) for x in history]
    result = await graph.ainvoke({"messages": msgs + [HumanMessage(content=text)], "user_id": user_id})
    response = OrderSupportResponse.model_validate_json(result["messages"][-1].content)
    await memory.append(session_id, "user", text)
    await memory.append(session_id, "assistant", response.message)
    return response.model_dump()
