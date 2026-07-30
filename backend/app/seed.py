from fastapi import APIRouter, HTTPException
from datetime import datetime
from app.database import get_db
from app.modules.auth.utils import hash_password

router = APIRouter(prefix="/api/seed", tags=["seed"])

@router.post("")
async def seed_data():
    db = get_db()
    
    # Check if test users exist
    alice = await db.users.find_one({"username": "alice"})
    bob = await db.users.find_one({"username": "bob"})
    charlie = await db.users.find_one({"username": "charlie"})
    
    now = datetime.utcnow().isoformat()
    pass_hash = hash_password("password123")
    
    if not alice:
        res = await db.users.insert_one({
            "phone": "+15550101",
            "email": "alice@campus.edu",
            "username": "alice",
            "display_name": "Alice Smith",
            "password_hash": pass_hash,
            "created_at": now
        })
        alice = {"_id": res.inserted_id, "username": "alice"}

    if not bob:
        res = await db.users.insert_one({
            "phone": "+15550102",
            "email": "bob@campus.edu",
            "username": "bob",
            "display_name": "Bob Jones",
            "password_hash": pass_hash,
            "created_at": now
        })
        bob = {"_id": res.inserted_id, "username": "bob"}
        
    if not charlie:
        res = await db.users.insert_one({
            "phone": "+15550103",
            "email": "charlie@campus.edu",
            "username": "charlie",
            "display_name": "Charlie Brown",
            "password_hash": pass_hash,
            "created_at": now
        })
        charlie = {"_id": res.inserted_id, "username": "charlie"}
        
    alice_id = str(alice["_id"])
    bob_id = str(bob["_id"])
    charlie_id = str(charlie["_id"])
    
    # Establish mutual friendship edges if not existing
    async def ensure_friendship(u1: str, u2: str):
        edge = await db.friend_edges.find_one({
            "$or": [
                {"user_id": u1, "friend_id": u2},
                {"user_id": u2, "friend_id": u1}
            ]
        })
        if not edge:
            await db.friend_edges.insert_one({
                "user_id": u1,
                "friend_id": u2,
                "status": "accepted",
                "created_at": now
            })
            
    await ensure_friendship(alice_id, bob_id)
    await ensure_friendship(alice_id, charlie_id)
    await ensure_friendship(bob_id, charlie_id)
    
    return {
        "message": "Seed completed successfully!",
        "test_users": [
            {"username": "alice", "password": "password123"},
            {"username": "bob", "password": "password123"},
            {"username": "charlie", "password": "password123"}
        ]
    }
