import httpx
from fastapi import Request


def get_spring_boot_client(request: Request) -> httpx.AsyncClient:
    """Dependency for future services that call Spring Boot-owned APIs."""
    return request.app.state.spring_boot_client
