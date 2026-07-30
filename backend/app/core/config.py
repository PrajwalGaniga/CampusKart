"""
Centralized application settings.
All hardcoded values live here — read from environment/.env file.
"""

from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import Optional


class Settings(BaseSettings):
    # ── Project ───────────────────────────────────────────────────────────────
    PROJECT_NAME: str = "CampusPulse"
    ENVIRONMENT: str = "development"  # development | production
    VERSION: str = "1.0.0"

    # ── MongoDB ───────────────────────────────────────────────────────────────
    MONGODB_URI: str
    DATABASE_NAME: str = "campuspulse"

    # ── JWT / Auth ────────────────────────────────────────────────────────────
    SECRET_KEY: str
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # ── Ask / Reply ───────────────────────────────────────────────────────────
    ASK_MAX_REPLIES: int = 5
    ASK_DEFAULT_TTL_MINUTES: int = 20
    ASK_MAX_TTL_MINUTES: int = 1440  # 24 h

    # ── WebSocket ─────────────────────────────────────────────────────────────
    WS_HEARTBEAT_SECONDS: int = 30

    # ── CORS ──────────────────────────────────────────────────────────────────
    CORS_ORIGINS: list[str] = ["*"]

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )


settings = Settings()
