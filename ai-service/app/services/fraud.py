from typing import TypedDict, Annotated
from langgraph.graph import StateGraph, END
from langchain_core.messages import HumanMessage, AIMessage, ToolMessage
from .llm import llm
from ..tools.fraud import get_order_history, get_vendor_history
from ..schemas.agentic import FraudCase

class State(TypedDict):
    messages: Annotated[list, list.__add__]

tools = {"get_order_history": get_order_history, "get_vendor_history": get_vendor_history}

async def agent(state: State):
    model = llm().bind_tools(list(tools.values()))
    prompt = ("You are a fraud investigation agent. This order was already flagged by a cheap rule. "
              "Dynamically decide what evidence to retrieve next. Cross-reference customer and vendor history. "
              "Never execute block/suspend. Case=" + str(state["messages"]))
    return {"messages": [await model.ainvoke([HumanMessage(content=prompt)])]}

async def tool_node(state: State):
    out=[]
    for call in getattr(state["messages"][-1], "tool_calls", []):
        out.append(ToolMessage(content=str(await tools[call["name"]].ainvoke(call["args"])), tool_call_id=call["id"]))
    return {"messages": out}

def route(state: State):
    return "tools" if getattr(state["messages"][-1], "tool_calls", []) else "final"

async def final_node(state: State):
    result=await llm().with_structured_output(FraudCase).ainvoke([HumanMessage(content=(
        "Create a fraud case card from the collected evidence. Recommendation CLEAR, FLAG or BLOCK; "
        "BLOCK is only a recommendation and always requires human approval. Evidence="+str(state["messages"])))])
    return {"messages":[AIMessage(content=result.model_dump_json())]}

g=StateGraph(State); g.add_node("agent",agent); g.add_node("tools",tool_node); g.add_node("final",final_node); g.set_entry_point("agent")
g.add_conditional_edges("agent",route,{"tools":"tools","final":"final"}); g.add_edge("tools","agent"); g.add_edge("final",END); graph=g.compile()

async def run(order: dict)->dict:
    r=await graph.ainvoke({"messages":[HumanMessage(content=str(order))]})
    return FraudCase.model_validate_json(r["messages"][-1].content).model_dump()
