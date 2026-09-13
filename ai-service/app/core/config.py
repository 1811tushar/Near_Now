import os
from dataclasses import dataclass

from dotenv import load_dotenv


load_dotenv()


@dataclass(frozen=True)
class Settings:
    internal_api_key: str
    spring_boot_base_url: str
    spring_boot_timeout_seconds: float


def _require(name: str) -> str:
    value = os.getenv(name, "")
    if not value:
        raise RuntimeError(f"{name} must be set")
    return value


settings = Settings(
    internal_api_key=_require("INTERNAL_API_KEY"),
    spring_boot_base_url=os.getenv("SPRING_BOOT_BASE_URL", "http://backend:8080"),
    spring_boot_timeout_seconds=float(os.getenv("SPRING_BOOT_TIMEOUT_SECONDS", "10")),
)
