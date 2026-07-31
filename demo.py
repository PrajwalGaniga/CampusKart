import requests
import time
import random

BASE_URL = "http://127.0.0.1:41273/api/v1"

def req_headers(token):
    return {"Authorization": f"Bearer {token}"}

# We will use realistic names so the dashboard looks great!
SUFFIX = f"_{random.randint(1000, 9999)}"
users_data = [
    {"username": f"prajwal{SUFFIX}", "display_name": f"Prajwal G", "email": f"p{SUFFIX}@demo.com", "password": "password123", "department": "CS", "year": 1, "section": "A"},
    {"username": f"Ishwarya{SUFFIX}", "display_name": f"Amrita", "email": f"a{SUFFIX}@demo.com", "password": "password123", "department": "CS", "year": 1, "section": "A"},
    {"username": f"Pavitra{SUFFIX}", "display_name": f"Rahul M", "email": f"r{SUFFIX}@demo.com", "password": "password123", "department": "CS", "year": 1, "section": "A"},
    {"username": f"Sanvi{SUFFIX}", "display_name": f"Sneha K", "email": f"s{SUFFIX}@demo.com", "password": "password123", "department": "CS", "year": 1, "section": "A"},
    {"username": f"Thejas{SUFFIX}", "display_name": f"Vikram", "email": f"v{SUFFIX}@demo.com", "password": "password123", "department": "CS", "year": 1, "section": "A"}
]

def main():
    tokens = {}

    print("Registering users and acquiring tokens...")
    for u in users_data:
        # Ignore if already registered
        requests.post(f"{BASE_URL}/auth/register", json=u)
        # Login to get token
        res = requests.post(f"{BASE_URL}/auth/login", json={"username": u["username"], "password": u["password"]})
        if res.status_code == 200:
            tokens[u["username"]] = res.json()["access_token"]
        else:
            print(f"Failed to login {u['username']}: {res.text}")

    print("Forming friendships...")
    usernames = list(tokens.keys())
    for i in range(len(usernames)):
        for j in range(i + 1, len(usernames)):
            u1 = usernames[i]
            u2 = usernames[j]
            # u1 sends request to u2
            requests.post(f"{BASE_URL}/friends/request", json={"username": u2}, headers=req_headers(tokens[u1]))
            # u2 checks pending and accepts
            pending_res = requests.get(f"{BASE_URL}/friends/pending", headers=req_headers(tokens[u2]))
            if pending_res.status_code == 200:
                for req in pending_res.json():
                    if req["username"] == u1:
                        requests.post(f"{BASE_URL}/friends/accept", json={"request_id": req["request_id"]}, headers=req_headers(tokens[u2]))

    print("Starting simulation loop... (Press CTRL+C to stop)")
    categories = ["ACADEMIC", "ITEMS", "FOOD", "TRANSPORT", "LOCATION", "EMERGENCY"]
    try:
        while True:
            # 1. Random user creates an ask
            asker = random.choice(usernames)
            ask_res = requests.post(
                f"{BASE_URL}/asks/",
                json={
                    "title": f"Need help with {random.choice(['assignment', 'notes', 'project', 'lunch', 'directions'])}",
                    "description": "Can someone help me out real quick?",
                    "category": random.choice(categories),
                    "location": random.choice(["Library", "Cafeteria", "Block A", "Hostel"]),
                    "expires_in_minutes": 20
                },
                headers=req_headers(tokens[asker])
            )
            
            if ask_res.status_code == 200:
                ask_id = ask_res.json()["id"]
                print(f"[{asker}] created ask {ask_id}")
                time.sleep(random.uniform(2, 4))
                
                # 2. Random friend replies
                replier = random.choice([u for u in usernames if u != asker])
                reply_res = requests.post(
                    f"{BASE_URL}/asks/{ask_id}/reply",
                    json={"message": "I'm on my way!", "arrival_eta_minutes": 5},
                    headers=req_headers(tokens[replier])
                )
                
                if reply_res.status_code == 200:
                    print(f"[{replier}] replied to ask {ask_id}")
                    time.sleep(random.uniform(2, 4))
                    
                    # 3. Get replies to find reply_id
                    replies = requests.get(f"{BASE_URL}/asks/{ask_id}/replies", headers=req_headers(tokens[asker])).json()
                    if replies:
                        reply_id = replies[0]["id"]
                        requests.post(
                            f"{BASE_URL}/asks/{ask_id}/resolve",
                            json={"reply_id": reply_id},
                            headers=req_headers(tokens[asker])
                        )
                        print(f"[{asker}] resolved ask {ask_id} with {replier}")
                    else:
                        print(f"[ERROR] No replies found for ask {ask_id}, skipping resolve")
                    
            # Wait a bit before next ask
            time.sleep(random.uniform(3, 5))
            
    except KeyboardInterrupt:
        print("Simulation stopped.")

if __name__ == "__main__":
    main()
