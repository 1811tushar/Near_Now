from typing import TypedDict, Annotated, Any
from langgraph.graph import StateGraph, END
from langchain_core.messages import HumanMessage, AIMessage, ToolMessage
from .llm import llm
from ..tools.shopping import search_products, price_filter
from ..schemas.agentic import ShoppingResponse
from .memory import ConversationMemory

class State(TypedDict):
    messages: Annotated[list, list.__add__]
    products: list[dict[str, Any]]

tools={"search_products":search_products,"price_filter":price_filter}

async def agent(state: State):
    model=llm().bind_tools(list(tools.values()))
    prompt=("You are a NearNow shopping agent. Dynamically decide whether search and price filtering are needed. "
            "Never call add-to-cart. If asked to add/buy, propose ADD_TO_CART with human approval. User="+str(state["messages"]))
    return {"messages":[await model.ainvoke([HumanMessage(content=prompt)])]}

async def tool_node(state: State):
    out=[]
    captured_products = None
    for call in getattr(state["messages"][-1],"tool_calls",[]):
        result = await tools[call["name"]].ainvoke(call["args"])
        out.append(ToolMessage(content=str(result),tool_call_id=call["id"]))
        # search_products / price_filter both return list[dict] straight from
        # Spring Boot — keep the most recent one verbatim so real product IDs
        # never have to survive an LLM JSON round-trip.
        if isinstance(result, list) and all(isinstance(item, dict) for item in result):
            captured_products = result
    update: dict[str, Any] = {"messages": out}
    if captured_products is not None:
        update["products"] = captured_products
    return update

def route(state): return "tools" if getattr(state["messages"][-1],"tool_calls",[]) else "final"

async def final_node(state):
    r=await llm().with_structured_output(ShoppingResponse).ainvoke([HumanMessage(content=(
        "Create concise shopping response from evidence. If user requested add/buy, require human approval and "
        "propose ADD_TO_CART; never execute. Evidence="+str(state["messages"])))])
    # Never trust the LLM's own regenerated `products` field — it can drop or
    # renumber real database IDs when re-serializing JSON from text evidence.
    # Attach the actual tool-call output captured in state instead.
    response = r.model_copy(update={"products": state.get("products", [])})
    return {"messages":[AIMessage(content=response.model_dump_json())]}

g=StateGraph(State); g.add_node("agent",agent); g.add_node("tools",tool_node); g.add_node("final",final_node); g.set_entry_point("agent")
g.add_conditional_edges("agent",route,{"tools":"tools","final":"final"}); g.add_edge("tools","agent"); g.add_edge("final",END); graph=g.compile()

memory=ConversationMemory()
async def chat(user_id:int,session_id:str,text:str)->dict:
    history=await memory.load(session_id)
    msgs=[HumanMessage(content=x["content"]) if x["role"]=="user" else AIMessage(content=x["content"]) for x in history]
    r=await graph.ainvoke({"messages":msgs+[HumanMessage(content=text)]})
    out=ShoppingResponse.model_validate_json(r["messages"][-1].content)
    await memory.append(session_id,"user",text); await memory.append(session_id,"assistant",out.message)
    return out.model_dump()