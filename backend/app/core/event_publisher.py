"""
Real EventPublisher — wires service events into WebSocket broadcasts.

Replaces the previous stub so that every action in the system
immediately pushes a real-time update to the correct audience.
"""

import logging
from app.core.ws_manager import manager

logger = logging.getLogger(__name__)


class EventPublisher:

    # ──────────────────────────────────────────────
    # Ask Events
    # ──────────────────────────────────────────────

    async def publish_ask_created(self, ask_id: str, requester_id: str, ask_data: dict):
        """Broadcast new ask to the public dashboard and privately to friends."""
        logger.info(f"[EVENT] ask_created ask_id={ask_id}")
        
        # Broadcast to public dashboard
        await manager.broadcast_public("ask_created", {
            "ask_id": ask_id,
            "requester_id": requester_id,
            **ask_data
        })
        
        # Private broadcast only to friends
        try:
            from app.repositories import friend_repository as friend_repo
            friends = await friend_repo.list_friends(requester_id)
            for f in friends:
                friend_id = f.user2 if f.user1 == requester_id else f.user1
                await manager.send_to_user(friend_id, "ask_created", {
                    "ask_id": ask_id,
                    "requester_id": requester_id,
                    **ask_data
                })
        except Exception as e:
            logger.error(f"Failed to push private ask_created to friends: {e}")

    async def publish_reply_created(self, ask_id: str, reply_id: str, responder_id: str):
        """Tell the ask requester that a reply arrived."""
        logger.info(f"[EVENT] reply_created ask_id={ask_id} reply_id={reply_id}")
        # The service layer supplies requester_id separately via send_to_user in the route
        await manager.broadcast_public("reply_created", {
            "ask_id": ask_id,
            "reply_id": reply_id,
            "responder_id": responder_id
        })

    async def publish_ask_locked(self, ask_id: str):
        """Broadcast that an ask is now locked (5 replies reached)."""
        logger.info(f"[EVENT] ask_locked ask_id={ask_id}")
        await manager.broadcast_public("ask_locked", {"ask_id": ask_id})

    async def publish_ask_resolved(self, ask_id: str, resolved_by_reply_id: str):
        """Broadcast that an ask was resolved."""
        logger.info(f"[EVENT] ask_resolved ask_id={ask_id}")
        await manager.broadcast_public("ask_resolved", {
            "ask_id": ask_id,
            "resolved_by_reply_id": resolved_by_reply_id
        })

    async def publish_ask_expired(self, ask_id: str):
        """Broadcast that an ask expired (TTL)."""
        logger.info(f"[EVENT] ask_expired ask_id={ask_id}")
        await manager.broadcast_public("ask_expired", {"ask_id": ask_id})

    # ──────────────────────────────────────────────
    # Private Notification Events
    # ──────────────────────────────────────────────

    async def send_notification(self, user_id: str, title: str, message: str, notif_type: str):
        """Push a personal notification to a user's private WS connections."""
        logger.info(f"[EVENT] notification user={user_id} type={notif_type}")
        await manager.send_to_user(user_id, "notification", {
            "title": title,
            "message": message,
            "type": notif_type
        })

    async def send_friend_request(self, to_user_id: str, from_username: str, request_id: str):
        """Notify a user that they have a new friend request."""
        logger.info(f"[EVENT] friend_request to={to_user_id} from={from_username}")
        await manager.send_to_user(to_user_id, "friend_request", {
            "from_username": from_username,
            "request_id": request_id
        })

    async def send_friend_accepted(self, to_user_id: str, from_username: str):
        """Notify a user that their friend request was accepted."""
        logger.info(f"[EVENT] friend_accepted to={to_user_id} from={from_username}")
        await manager.send_to_user(to_user_id, "friend_accepted", {
            "from_username": from_username
        })


event_publisher = EventPublisher()
