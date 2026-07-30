from typing import List, Optional
from app.models.user import User
from app.models.friend_request import FriendRequest
from app.models.friendship import Friendship
from beanie.operators import Or, And, RegEx
from bson import ObjectId

async def search_users(query: str, current_user_id: str) -> List[User]:
    users = await User.find(
        RegEx(User.username, f"(?i){query}"),
        User.id != ObjectId(current_user_id),
        User.is_active == True
    ).to_list()
    return users

async def find_user_by_username(username: str) -> Optional[User]:
    return await User.find_one(User.username == username)

async def find_user_by_id(user_id: str) -> Optional[User]:
    return await User.get(ObjectId(user_id))

async def create_friend_request(sender_id: str, receiver_id: str) -> FriendRequest:
    fr = FriendRequest(sender_id=sender_id, receiver_id=receiver_id)
    await fr.insert()
    return fr

async def get_pending_request(sender_id: str, receiver_id: str) -> Optional[FriendRequest]:
    return await FriendRequest.find_one(
        FriendRequest.sender_id == sender_id,
        FriendRequest.receiver_id == receiver_id,
        FriendRequest.status == "PENDING"
    )

async def get_request_by_id(request_id: str) -> Optional[FriendRequest]:
    return await FriendRequest.get(ObjectId(request_id))

async def get_incoming_pending_requests(user_id: str) -> List[FriendRequest]:
    return await FriendRequest.find(
        FriendRequest.receiver_id == user_id,
        FriendRequest.status == "PENDING"
    ).to_list()

async def get_sent_requests(user_id: str) -> List[FriendRequest]:
    return await FriendRequest.find(
        FriendRequest.sender_id == user_id,
        FriendRequest.status == "PENDING"
    ).to_list()

async def update_friend_request(request: FriendRequest) -> FriendRequest:
    await request.save()
    return request

async def are_friends(user1_id: str, user2_id: str) -> bool:
    friendship = await Friendship.find_one(
        Or(
            And(Friendship.user1 == user1_id, Friendship.user2 == user2_id),
            And(Friendship.user1 == user2_id, Friendship.user2 == user1_id)
        )
    )
    return friendship is not None

async def create_friendship(user1_id: str, user2_id: str) -> Friendship:
    f = Friendship(user1=user1_id, user2=user2_id)
    await f.insert()
    return f

async def delete_friendship(user1_id: str, user2_id: str) -> bool:
    friendship = await Friendship.find_one(
        Or(
            And(Friendship.user1 == user1_id, Friendship.user2 == user2_id),
            And(Friendship.user1 == user2_id, Friendship.user2 == user1_id)
        )
    )
    if friendship:
        await friendship.delete()
        return True
    return False

async def list_friends(user_id: str) -> List[Friendship]:
    return await Friendship.find(
        Or(Friendship.user1 == user_id, Friendship.user2 == user_id)
    ).to_list()

async def increment_friend_count(user_id: str, amount: int = 1):
    await User.find_one({"_id": ObjectId(user_id)}).inc({User.friends_count: amount})

async def decrement_friend_count(user_id: str, amount: int = 1):
    await User.find_one({"_id": ObjectId(user_id)}).inc({User.friends_count: -amount})
