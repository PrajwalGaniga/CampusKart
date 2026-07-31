"""
CampusPulse — FastAPI Application Entry Point

Mounts:
  /api/v1      REST API (auth, friends, asks)
  /ws          WebSocket (public dashboard + private notifications)
  /            root health ping
  /health      detailed health check
"""

import logging
from contextlib import asynccontextmanager
from datetime import datetime, timezone

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.staticfiles import StaticFiles

from app.core.config import settings
from app.core.db import init_db
from app.core.exceptions import register_exception_handlers
from app.core.middleware import LoggingMiddleware, RequestIDMiddleware, TimingMiddleware
from app.api.api import api_router
from app.api.endpoints import websockets

# ── Logging setup ─────────────────────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)-8s | %(name)s | %(message)s",
)
logger = logging.getLogger(__name__)


# ── Lifespan ──────────────────────────────────────────────────────────────────
@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info(f"Starting {settings.PROJECT_NAME} v{settings.VERSION} [{settings.ENVIRONMENT}]")
    await init_db()
    logger.info("MongoDB ready.")
    yield
    logger.info(f"Shutting down {settings.PROJECT_NAME}.")


# ── App ────────────────────────────────────────────────────────────────────────
app = FastAPI(
    title=f"{settings.PROJECT_NAME} API",
    description=(
        "Real-time campus social platform backend.\n\n"
        "### WebSocket Endpoints\n"
        "- `ws://host/ws/public` — Public feed (no auth)\n"
        "- `ws://host/ws/private?token=<jwt>` — Private notifications (JWT required)\n"
    ),
    version=settings.VERSION,
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_tags=[
        {"name": "auth",       "description": "Registration, login, token management"},
        {"name": "friends",    "description": "Friend requests, acceptance, listing"},
        {"name": "asks",       "description": "Ask creation, replies, resolution"},
        {"name": "websockets", "description": "Real-time WebSocket connections"},
        {"name": "health",     "description": "Service health & readiness probes"},
    ],
)

# ── Exception handlers ─────────────────────────────────────────────────────────
register_exception_handlers(app)

# ── Middleware (order matters — outermost applied last) ────────────────────────
app.add_middleware(LoggingMiddleware)
app.add_middleware(TimingMiddleware)
app.add_middleware(RequestIDMiddleware)
app.add_middleware(GZipMiddleware, minimum_size=1000)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Routers ────────────────────────────────────────────────────────────────────
app.include_router(api_router,        prefix="/api/v1")
app.include_router(websockets.router, prefix="/ws", tags=["websockets"])

# Mount static files
app.mount("/static", StaticFiles(directory="app/static"), name="static")


# ── Health Checks ──────────────────────────────────────────────────────────────
@app.get("/", tags=["health"], summary="Root ping")
async def root():
    """Quick liveness probe."""
    return {
        "service": settings.PROJECT_NAME,
        "status": "Running",
        "version": settings.VERSION,
    }


@app.get("/health", tags=["health"], summary="Detailed health check")
async def health():
    """
    Returns database connectivity status, WebSocket connection counts,
    and current server time.
    """
    from app.core.ws_manager import manager
    from motor.motor_asyncio import AsyncIOMotorClient

    # Ping MongoDB
    db_status = "ok"
    try:
        client = AsyncIOMotorClient(settings.MONGODB_URI, serverSelectionTimeoutMS=2000)
        await client.admin.command("ping")
    except Exception as e:
        db_status = f"error: {e}"

    return {
        "status": "ok" if db_status == "ok" else "degraded",
        "server_time": datetime.now(timezone.utc).isoformat(),
        "environment": settings.ENVIRONMENT,
        "database": {
            "status": db_status,
            "name": settings.DATABASE_NAME,
        },
        "websocket": {
            "public_connections": len(manager.public_connections),
            "private_users": len(manager.private_connections),
            "private_sockets": sum(len(v) for v in manager.private_connections.values()),
        },
    }
