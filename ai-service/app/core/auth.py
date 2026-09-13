import secrets
from typing import Annotated

from fastapi import Header, HTTPException, status

from app.core.config import settings


async def require_internal_api_key(
    x_internal_api_key: Annotated[str | None, Header()] = None,
) -> None:
    """Layer 1/2 shared-secret check required by every internal AI endpoint."""
    if x_internal_api_key is None or not secrets.compare_digest(
        x_internal_api_key, settings.internal_api_key
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid internal API key",
        )
