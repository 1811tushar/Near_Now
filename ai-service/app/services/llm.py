import os
from langchain_google_genai import ChatGoogleGenerativeAI


def llm():
    return ChatGoogleGenerativeAI(
        model=os.getenv("GEMINI_MODEL", "gemini-2.0-flash"),
        temperature=0,
        google_api_key=os.environ["GEMINI_API_KEY"],
    )
