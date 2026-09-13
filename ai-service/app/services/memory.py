import json
import os
import redis.asyncio as redis


class ConversationMemory:
    def __init__(self):
        self.redis = redis.from_url(os.getenv("REDIS_URL", "redis://redis:6379/0"), decode_responses=True)
        self.ttl = int(os.getenv("AI_SESSION_TTL_SECONDS", "1800"))

    async def load(self, session_id: str) -> list[dict]:
        raw = await self.redis.get(f"ai:session:{session_id}")
        return json.loads(raw) if raw else []

    async def append(self, session_id: str, role: str, content: str) -> None:
        history = await self.load(session_id)
        history.append({"role": role, "content": content})
        history = history[-20:]
        await self.redis.setex(f"ai:session:{session_id}", self.ttl, json.dumps(history))
