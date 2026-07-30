from typing import Dict, Set
from fastapi import WebSocket
import logging
import json

logger = logging.getLogger("uvicorn")

class ConnectionManager:
    def __init__(self):
        # Map user_id (str) -> Set[WebSocket]
        self.user_connections: Dict[str, Set[WebSocket]] = {}
        # Set of active WebSockets listening to public board
        self.board_connections: Set[WebSocket] = set()

    async def connect_user(self, user_id: str, websocket: WebSocket):
        await websocket.accept()
        if user_id not in self.user_connections:
            self.user_connections[user_id] = set()
        self.user_connections[user_id].add(websocket)
        logger.info(f"WebSocket connected for user {user_id}")

    def disconnect_user(self, user_id: str, websocket: WebSocket):
        if user_id in self.user_connections:
            self.user_connections[user_id].discard(websocket)
            if not self.user_connections[user_id]:
                del self.user_connections[user_id]
        logger.info(f"WebSocket disconnected for user {user_id}")

    async def connect_board(self, websocket: WebSocket):
        await websocket.accept()
        self.board_connections.add(websocket)
        logger.info("WebSocket connected for public board")

    def disconnect_board(self, websocket: WebSocket):
        self.board_connections.discard(websocket)
        logger.info("WebSocket disconnected for public board")

    async def send_to_user(self, user_id: str, message: dict):
        if user_id in self.user_connections:
            dead_sockets = set()
            for ws in list(self.user_connections[user_id]):
                try:
                    await ws.send_text(json.dumps(message))
                except Exception as e:
                    logger.warning(f"Error sending to user {user_id}: {e}")
                    dead_sockets.add(ws)
            for ws in dead_sockets:
                self.disconnect_user(user_id, ws)

    async def send_to_users(self, user_ids: list, message: dict):
        for uid in user_ids:
            await self.send_to_user(uid, message)

    async def broadcast_all_users(self, message: dict):
        for user_id in list(self.user_connections.keys()):
            await self.send_to_user(user_id, message)

    async def broadcast_board(self, message: dict):
        dead_sockets = set()
        for ws in list(self.board_connections):
            try:
                await ws.send_text(json.dumps(message))
            except Exception as e:
                logger.warning(f"Error broadcasting to board: {e}")
                dead_sockets.add(ws)
        for ws in dead_sockets:
            self.disconnect_board(ws)

manager = ConnectionManager()
