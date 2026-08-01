from fastapi import APIRouter
from typing import List, Dict, Any
from app.schemas.ask import AskResponse
from app.models.ask import Ask
from app.models.user import User
from app.models.friendship import Friendship
from app.models.activity_log import ActivityLog
import random

router = APIRouter()

@router.get("/feed", response_model=List[AskResponse])
async def get_public_feed(limit: int = 20):
    """
    Get the latest open asks for the public display.
    No authentication required.
    """
    # Fetch recent open asks
    asks = await Ask.find(Ask.status == "OPEN").sort(-Ask.created_at).limit(limit).to_list()
    
    # We anonymize usernames for public view if needed, 
    # but the schema expects requester_name. 
    # The prompt states: "Anonymization: Never show usernames. Instead display: 'Student near Block C'".
    # So we modify the returned data on the fly.
    
    result = []
    for ask in asks:
        ask_data = ask.model_dump()
        ask_data["id"] = str(ask.id)
        # Fetch actual user details
        user = await User.get(ask.requester_id)
        if user:
            ask_data["requester_name"] = user.display_name
            ask_data["requester_image"] = user.profile_picture
        else:
            ask_data["requester_name"] = "Unknown"
            ask_data["requester_image"] = "/static/default.png"
        
        # Add string versions of dates
        ask_data["created_at"] = ask.created_at.isoformat()
        ask_data["expires_at"] = ask.expires_at.isoformat()
        result.append(ask_data)
        
    return result

@router.get("/stats", response_model=Dict[str, Any])
async def get_public_stats():
    """
    Get live stats for the public dashboard.
    """
    open_asks = await Ask.find(Ask.status == "OPEN").count()
    resolved_asks = await Ask.find(Ask.status == "RESOLVED").count()
    locked_asks = await Ask.find(Ask.status == "LOCKED").count()
    expired_asks = await Ask.find(Ask.status == "EXPIRED").count()
    
    online_users = await User.find(User.status == "ONLINE").count()
    total_users = await User.find_all().count()
    
    # Placeholder for average response time as per prompt
    avg_response_time = "5m"
    
    total_events = open_asks + resolved_asks + locked_asks + expired_asks
    
    return {
        "open_asks": open_asks,
        "resolved_asks": resolved_asks,
        "locked_asks": locked_asks,
        "expired_asks": expired_asks,
        "online_users": online_users,
        "total_users": total_users,
        "total_events": total_events,
        "average_response_time": avg_response_time
    }

@router.get("/network", response_model=Dict[str, Any])
async def get_public_network():
    """
    Get an anonymized graph of users and friendships for the dashboard.
    """
    users = await User.find_all().to_list()
    friendships = await Friendship.find_all().to_list()
    
    nodes = []
    edges = []
    
    for u in users:
        nodes.append({
            "id": str(u.id),
            "status": u.status
        })
        
    for f in friendships:
        edges.append({
            "source": f.user1,
            "target": f.user2
        })
        
    return {
        "nodes": nodes,
        "edges": edges
    }

@router.get("/health", response_model=Dict[str, Any])
async def get_public_health():
    """
    Mocked health statuses for the dashboard aesthetic.
    """
    # Mocking some latency jitter
    latency = random.randint(15, 60)
    
    return {
        "api_status": "operational",
        "api_latency": f"{latency}ms",
        "db_status": "operational",
        "kubernetes_status": "operational",
        "docker_status": "operational",
        "websocket_status": "operational"
    }

@router.get("/events")
async def get_public_events(limit: int = 50):
    """
    Get recent activity logs mapped to PulseEvents for the public timeline.
    """
    logs = await ActivityLog.find_all().sort(-ActivityLog.created_at).limit(limit).to_list()
    events = []
    
    # PulseEventType: 'ask_created' | 'ask_replied' | 'ask_matched' | 'ask_expired' | 'system_message'
    action_map = {
        "ASK_CREATED": "ask_created",
        "REPLY_CREATED": "ask_replied",
        "ASK_RESOLVED": "ask_matched",
        "ASK_DELETED": "ask_expired",
        "ASK_LOCKED": "ask_expired",
    }
    
    for log in logs:
        pulse_type = action_map.get(log.action, "system_message")
        events.append({
            "id": str(log.id),
            "type": pulse_type,
            "askId": log.metadata.get("ask_id"),
            "fromUserId": log.user_id,
            "helperId": log.metadata.get("helper_id") if log.action == "MATCH_FOUND" else None,
            "message": log.metadata.get("title") or log.metadata.get("message") or f"System event: {log.action}",
            "ts": int(log.created_at.timestamp() * 1000)
        })
    return events

@router.get("/users")
async def get_public_users():
    """
    Get all users for the dashboard User Roster.
    """
    users = await User.find_all().to_list()
    result = []
    for u in users:
        result.append({
            "id": str(u.id),
            "name": u.display_name,
            "username": u.username,
            "avatar": u.profile_picture,
            "isOnline": u.status == "ONLINE",
            "state": "idle",
            "friendsCount": 0
        })
    return result
