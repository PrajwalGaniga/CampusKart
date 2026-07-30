"""
WebSocket Connection Manager.

Manages two types of WebSocket connections:
1. Public Dashboard  - any connected client receives global feed events
2. Private Notifications - per-user authenticated connections receive personal events
"""

import asyncio
import json
import logging
from collections import defaultdict
from datetime import datetime
from fastapi import WebSocket
from app.core.config import settings

logger = logging.getLogger(__name__)


def _json_safe(obj):
    """Convert types that are not JSON-serializable."""
    if isinstance(obj, datetime):
        return obj.isoformat()
    raise TypeError(f"Object of type {type(obj)} is not JSON serializable")


def _dumps(data: dict) -> str:
    return json.dumps(data, default=_json_safe)


class ConnectionManager:
    def __init__(self):
        # Public dashboard connections - no auth required
        self.public_connections: list[WebSocket] = []

        # Private per-user connections: user_id -> list of WebSocket
        # A user may have multiple tabs/devices
        self.private_connections: dict[str, list[WebSocket]] = defaultdict(list)

    # ──────────────────────────────────────────────
    # Public Dashboard
    # ──────────────────────────────────────────────

    async def connect_public(self, websocket: WebSocket):
        await websocket.accept()
        self.public_connections.append(websocket)
        logger.info(f"[WS PUBLIC] Connected. Total public: {len(self.public_connections)}")

    def disconnect_public(self, websocket: WebSocket):
        if websocket in self.public_connections:
            self.public_connections.remove(websocket)
        logger.info(f"[WS PUBLIC] Disconnected. Total public: {len(self.public_connections)}")

    async def broadcast_public(self, event: str, data: dict):
        """Send an event to every public dashboard subscriber."""
        payload = _dumps({"event": event, "data": data})
        dead = []
        for ws in self.public_connections:
            try:
                await ws.send_text(payload)
            except Exception:
                dead.append(ws)
        for ws in dead:
            self.disconnect_public(ws)

    # ──────────────────────────────────────────────
    # Private Notifications
    # ──────────────────────────────────────────────

    async def connect_private(self, websocket: WebSocket, user_id: str):
        await websocket.accept()
        self.private_connections[user_id].append(websocket)
        logger.info(f"[WS PRIVATE] user={user_id} connected. Sockets: {len(self.private_connections[user_id])}")
        asyncio.create_task(self._set_user_status(user_id, "ONLINE"))

    def disconnect_private(self, websocket: WebSocket, user_id: str):
        conns = self.private_connections.get(user_id, [])
        if websocket in conns:
            conns.remove(websocket)
        if not conns:
            self.private_connections.pop(user_id, None)
            asyncio.create_task(self._set_user_status(user_id, "OFFLINE"))
        logger.info(f"[WS PRIVATE] user={user_id} disconnected.")

    async def _set_user_status(self, user_id: str, status: str):
        try:
            from app.models.user import User
            user = await User.get(user_id)
            if user:
                user.status = status
                await user.save()
        except Exception as e:
            logger.error(f"Failed to set user {user_id} status to {status}: {e}")

    async def send_to_user(self, user_id: str, event: str, data: dict):
        """Send an event to all active connections of a specific user."""
        payload = _dumps({"event": event, "data": data})
        conns = list(self.private_connections.get(user_id, []))
        dead = []
        for ws in conns:
            try:
                await ws.send_text(payload)
            except Exception:
                dead.append(ws)
        for ws in dead:
            self.disconnect_private(ws, user_id)

    async def heartbeat(self, websocket: WebSocket, interval: int | None = None):
        """Send periodic ping to keep the connection alive."""
        if interval is None:
            interval = settings.WS_HEARTBEAT_SECONDS
        try:
            while True:
                await asyncio.sleep(interval)
                await websocket.send_text(json.dumps({"event": "ping"}))
        except Exception:
            pass  # Connection already closed; handled by caller


# Singleton
manager = ConnectionManager()
