"""
WebSocket Endpoints

Routes:
  WS /ws/public        - Public dashboard feed (no auth)
  WS /ws/private       - Private notifications (JWT required via query param)
"""

import asyncio
import json
import logging
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Query, status

from app.core.ws_manager import manager
from app.core.security import decode_access_token

logger = logging.getLogger(__name__)

router = APIRouter()


@router.websocket("/public")
async def ws_public(websocket: WebSocket):
    """
    Public WebSocket — broadcasts global feed events to all connected clients.
    No authentication required.
    """
    await manager.connect_public(websocket)
    try:
        # Send welcome message
        await websocket.send_text(json.dumps({
            "event": "connected",
            "data": {"message": "Connected to CampusPulse public feed"}
        }))

        # Keep connection alive; read pong/messages from client
        heartbeat_task = asyncio.create_task(manager.heartbeat(websocket))
        try:
            while True:
                data = await websocket.receive_text()
                # Client can send {"event": "pong"} in response to ping
        except WebSocketDisconnect:
            pass
        finally:
            heartbeat_task.cancel()
    finally:
        manager.disconnect_public(websocket)


@router.websocket("/private")
async def ws_private(
    websocket: WebSocket,
    token: str = Query(..., description="JWT access token for authentication")
):
    """
    Private WebSocket — delivers personal notifications to the authenticated user.
    Requires a valid JWT token as a query parameter: /ws/private?token=<jwt>
    """
    # Authenticate before accepting
    payload = decode_access_token(token)
    if payload is None:
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
        logger.warning("[WS PRIVATE] Rejected connection — invalid/expired token")
        return

    user_id: str = payload.get("sub")
    if not user_id:
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
        return

    await manager.connect_private(websocket, user_id)
    try:
        await websocket.send_text(json.dumps({
            "event": "connected",
            "data": {"message": f"Connected to private channel", "user_id": user_id}
        }))

        heartbeat_task = asyncio.create_task(manager.heartbeat(websocket))
        try:
            while True:
                # Receive client messages (pong, acks, etc.)
                await websocket.receive_text()
        except WebSocketDisconnect:
            pass
        finally:
            heartbeat_task.cancel()
    finally:
        manager.disconnect_private(websocket, user_id)
