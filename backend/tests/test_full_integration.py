"""
CampusPulse — Full Integration Test Suite
Uses known test accounts: prajwal / ishwarya (password: 12345678)
"""

import requests
import asyncio
import random
import string
import json
import sys

sys.stdout.reconfigure(encoding="utf-8")

BASE = "http://localhost:8000/api/v1"
WS_BASE = "ws://localhost:8000/ws"

PASS_ALL = True
results = []


def rnd(n=6):
    return "".join(random.choices(string.ascii_lowercase, k=n))


def ok(label, condition, detail=""):
    global PASS_ALL
    if not condition:
        PASS_ALL = False
    status = "PASS" if condition else "FAIL"
    msg = f"  [{status}] {label}"
    if detail and not condition:
        msg += f"  => {detail}"
    print(msg)
    results.append((label, condition))
    return condition


def section(title):
    print(f"\n{'='*55}")
    print(f"  {title}")
    print(f"{'='*55}")


def post(path, **kw):
    return requests.post(f"{BASE}{path}", **kw)


def get(path, **kw):
    return requests.get(f"{BASE}{path}", **kw)


def delete(path, **kw):
    return requests.delete(f"{BASE}{path}", **kw)


def hdr(token):
    return {"Authorization": f"Bearer {token}"}


def register_and_login(suffix=None):
    if not suffix:
        suffix = rnd()
    uname = f"u_{suffix}"
    r = post("/auth/register", json={
        "username": uname,
        "email": f"{uname}@campus.com",
        "password": "Pass1234!",
        "display_name": f"User {suffix}",
        "department": "CS",
        "year": 1,
        "section": "A"
    })
    if r.status_code not in (200, 201):
        return uname, None
    r2 = post("/auth/login", json={"username": uname, "password": "Pass1234!"})
    return uname, r2.json().get("access_token")


# ─────────────────────────────────────────────────────────
# 1. HEALTH
# ─────────────────────────────────────────────────────────
section("1. Health Checks")

r = requests.get("http://localhost:8000/")
ok("GET / returns 200", r.status_code == 200)
ok("GET / has 'service' key", "service" in r.json())
ok("GET / status is Running", r.json().get("status") == "Running")

r = requests.get("http://localhost:8000/health")
ok("GET /health returns 200", r.status_code == 200)
ok("GET /health database.status == ok", r.json().get("database", {}).get("status") == "ok")
ok("GET /health has 'websocket' key", "websocket" in r.json())
ok("GET /health has server_time", "server_time" in r.json())


# ─────────────────────────────────────────────────────────
# 2. AUTH
# ─────────────────────────────────────────────────────────
section("2. Authentication")

suf = rnd()
r = post("/auth/register", json={
    "username": f"reg_{suf}",
    "email": f"reg_{suf}@campus.com",
    "password": "Pass1234!",
    "display_name": "Test Reg",
    "department": "CS",
    "year": 2,
    "section": "B"
})
ok("Register new user -> 201", r.status_code == 201, r.text)

# Duplicate
r2 = post("/auth/register", json={
    "username": f"reg_{suf}",
    "email": f"reg_{suf}@campus.com",
    "password": "Pass1234!",
    "display_name": "Test Reg",
    "department": "CS",
    "year": 2,
    "section": "B"
})
ok("Duplicate register -> 4xx", r2.status_code >= 400)

# Login
r = post("/auth/login", json={"username": f"reg_{suf}", "password": "Pass1234!"})
ok("Login -> 200", r.status_code == 200, r.text)
ok("Login returns access_token", "access_token" in r.json())

# Invalid password
r = post("/auth/login", json={"username": f"reg_{suf}", "password": "WrongPass"})
ok("Invalid password -> 401", r.status_code == 401)

# Nonexistent user
r = post("/auth/login", json={"username": "doesnotexist_xyz", "password": "Pass1234!"})
ok("Nonexistent user -> 401", r.status_code == 401)

# Invalid JWT
r = get("/asks/my", headers={"Authorization": "Bearer totally.invalid.jwt"})
ok("Invalid JWT -> 401", r.status_code == 401)

# Missing auth
r = get("/asks/my")
ok("No auth header -> 401", r.status_code == 401)


# ─────────────────────────────────────────────────────────
# 3. FRIENDS — using prajwal + new users
# ─────────────────────────────────────────────────────────
section("3. Friend Management")

r = post("/auth/login", json={"username": "prajwal", "password": "12345678"})
ok("prajwal login", r.status_code == 200)
prajwal_token = r.json().get("access_token", "")

r = post("/auth/login", json={"username": "ishwarya", "password": "12345678"})
ok("ishwarya login", r.status_code == 200)
ishwarya_token = r.json().get("access_token", "")

# Register two fresh users for clean friend tests
alice_name, alice_token = register_and_login("alice_" + rnd())
bob_name, bob_token = register_and_login("bob_" + rnd())
charlie_name, charlie_token = register_and_login("charlie_" + rnd())

ok("alice registered", alice_token is not None)
ok("bob registered", bob_token is not None)
ok("charlie registered", charlie_token is not None)

# Alice sends request to Bob
r = post("/friends/request", json={"username": bob_name}, headers=hdr(alice_token))
ok("Alice -> Bob friend request", r.status_code == 200, r.text)

# Duplicate
r = post("/friends/request", json={"username": bob_name}, headers=hdr(alice_token))
ok("Duplicate friend request -> 400", r.status_code == 400)

# Bob sees pending
r = get("/friends/pending", headers=hdr(bob_token))
ok("Bob sees pending requests", r.status_code == 200 and len(r.json()) >= 1)
req_id = r.json()[0]["request_id"] if r.json() else None

# Bob accepts
if req_id:
    r = post("/friends/accept", json={"request_id": req_id}, headers=hdr(bob_token))
    ok("Bob accepts Alice -> 200", r.status_code == 200, r.text)

# Check friends list
r = get("/friends/list", headers=hdr(alice_token))
ok("Alice has Bob in friend list", r.status_code == 200 and any(
    f.get("username") == bob_name for f in r.json()
))

# Alice sends to Charlie, then cancels
r = post("/friends/request", json={"username": charlie_name}, headers=hdr(alice_token))
ok("Alice -> Charlie request", r.status_code == 200)
reqs = get("/friends/sent", headers=hdr(alice_token)).json()
charlie_req_id = next((x["request_id"] for x in reqs if x.get("to_username") == charlie_name), None)
if charlie_req_id:
    r = post("/friends/cancel", json={"request_id": charlie_req_id}, headers=hdr(alice_token))
    ok("Alice cancels Charlie request -> 200", r.status_code == 200, r.text)

# Cannot send to self
r = post("/friends/request", json={"username": alice_name}, headers=hdr(alice_token))
ok("Cannot friend yourself -> 400", r.status_code == 400)

# Reject: Alice re-sends to Charlie, Charlie rejects
post("/friends/request", json={"username": charlie_name}, headers=hdr(alice_token))
pending = get("/friends/pending", headers=hdr(charlie_token)).json()
charlie_pending_id = next((x["request_id"] for x in pending if x.get("from_username") == alice_name), None)
if charlie_pending_id:
    r = post("/friends/reject", json={"request_id": charlie_pending_id}, headers=hdr(charlie_token))
    ok("Charlie rejects Alice -> 200", r.status_code == 200, r.text)


# ─────────────────────────────────────────────────────────
# 4. ASKS — using prajwal + ishwarya (already friends)
# ─────────────────────────────────────────────────────────
section("4. Ask Creation & Feed")

ask_payload = {
    "title": "Need physics notes",
    "description": "Anyone have semester 3 physics notes available?",
    "category": "ACADEMIC",
    "location": "Library Block B",
    "expires_in_minutes": 30
}

r = post("/asks/", json=ask_payload, headers=hdr(prajwal_token))
ok("Prajwal creates ask -> 200", r.status_code == 200, r.text)
ask_id = r.json().get("id") if r.status_code == 200 else None

# Feed
r = get("/asks/feed", headers=hdr(ishwarya_token))
ok("Ishwarya sees ask in feed", r.status_code == 200 and any(a["id"] == ask_id for a in r.json()))

# My asks
r = get("/asks/my", headers=hdr(prajwal_token))
ok("Prajwal sees own ask in /my", r.status_code == 200 and any(a["id"] == ask_id for a in r.json()))

# Invalid category
r = post("/asks/", json={**ask_payload, "category": "INVALID"}, headers=hdr(prajwal_token))
ok("Invalid category -> 422", r.status_code == 422)

# Invalid TTL
r = post("/asks/", json={**ask_payload, "expires_in_minutes": 9999}, headers=hdr(prajwal_token))
ok("TTL > 1440 -> 422", r.status_code == 422)

# Nonexistent ask
r = get("/asks/000000000000000000000000", headers=hdr(prajwal_token))
ok("Nonexistent ask -> 404", r.status_code == 404)

# Invalid ObjectId
r = get("/asks/not_an_id_at_all", headers=hdr(prajwal_token))
ok("Garbage ask ID -> 4xx", r.status_code >= 400)


section("5. Reply System")

# Cannot reply to own ask
r = post(f"/asks/{ask_id}/reply", json={"message": "replying myself"}, headers=hdr(prajwal_token))
ok("Cannot reply own ask -> 400", r.status_code == 400)

# Ishwarya replies
r = post(f"/asks/{ask_id}/reply", json={"message": "I have physics notes!"}, headers=hdr(ishwarya_token))
ok("Ishwarya replies -> 200", r.status_code == 200, r.text)

# Duplicate reply
r = post(f"/asks/{ask_id}/reply", json={"message": "Same again"}, headers=hdr(ishwarya_token))
ok("Duplicate reply -> 400", r.status_code == 400)

# Prajwal reads replies
r = get(f"/asks/{ask_id}/replies", headers=hdr(prajwal_token))
ok("Prajwal sees replies", r.status_code == 200 and len(r.json()) >= 1)
reply_id = r.json()[0]["id"] if r.json() else None

# Non-requester cannot read replies
r = get(f"/asks/{ask_id}/replies", headers=hdr(ishwarya_token))
ok("Ishwarya cannot view replies list -> 403", r.status_code == 403)

# Resolve
if reply_id:
    r = post(f"/asks/{ask_id}/resolve", json={"reply_id": reply_id}, headers=hdr(prajwal_token))
    ok("Prajwal resolves ask -> 200", r.status_code == 200, r.text)

# After resolve, ask gone from feed
r = get("/asks/feed", headers=hdr(ishwarya_token))
ok("Resolved ask gone from feed", not any(a["id"] == ask_id for a in r.json()))

# Delete ask
r2 = post("/asks/", json={**ask_payload, "title": "Delete me"}, headers=hdr(prajwal_token))
del_id = r2.json().get("id") if r2.status_code == 200 else None
if del_id:
    r = delete(f"/asks/{del_id}", headers=hdr(prajwal_token))
    ok("Delete own ask -> 200", r.status_code == 200)
    # Second delete should 404
    r = delete(f"/asks/{del_id}", headers=hdr(prajwal_token))
    ok("Delete again -> 404", r.status_code == 404)


section("6. Atomic Reply Lock (5-reply limit)")

r = post("/asks/", json={**ask_payload, "title": "Atomic lock test ask"}, headers=hdr(prajwal_token))
ok("Create lock-test ask", r.status_code == 200)
lock_ask_id = r.json().get("id") if r.status_code == 200 else None

# Register 5 temp users, make friends with prajwal, each replies
temp_tokens = []
for i in range(5):
    _, tk = register_and_login(f"lk{i}{rnd()}")
    if tk:
        post("/friends/request", json={"username": "prajwal"}, headers=hdr(tk))
        temp_tokens.append(tk)

# Prajwal accepts all pending
pending = get("/friends/pending", headers=hdr(prajwal_token)).json()
for pr in pending:
    post("/friends/accept", json={"request_id": pr["request_id"]}, headers=hdr(prajwal_token))

for i, tk in enumerate(temp_tokens):
    r = post(f"/asks/{lock_ask_id}/reply", json={"message": f"Reply #{i+1}"}, headers=hdr(tk))
    ok(f"Reply {i+1}/5 accepted", r.status_code == 200, r.text)

# 6th user — should be blocked
_, extra_token = register_and_login(f"extra_{rnd()}")
if extra_token:
    post("/friends/request", json={"username": "prajwal"}, headers=hdr(extra_token))
    pending = get("/friends/pending", headers=hdr(prajwal_token)).json()
    for pr in pending:
        post("/friends/accept", json={"request_id": pr["request_id"]}, headers=hdr(prajwal_token))
    r = post(f"/asks/{lock_ask_id}/reply", json={"message": "I am the 6th!"}, headers=hdr(extra_token))
    ok("6th reply blocked -> 409", r.status_code == 409, f"got {r.status_code}: {r.text}")


section("7. WebSocket")

async def test_ws():
    try:
        import websockets
    except ImportError:
        print("  [SKIP] websockets package not installed")
        return

    ws_ok = []

    # Public WS
    try:
        async with websockets.connect(f"{WS_BASE}/public") as ws:
            msg = json.loads(await asyncio.wait_for(ws.recv(), timeout=5))
            ws_ok.append(ok("Public WS connects + receives welcome", msg.get("event") == "connected"))
    except Exception as e:
        ws_ok.append(ok("Public WS connects", False, str(e)))

    # Private WS — valid JWT
    try:
        async with websockets.connect(f"{WS_BASE}/private?token={prajwal_token}") as ws:
            msg = json.loads(await asyncio.wait_for(ws.recv(), timeout=5))
            ws_ok.append(ok("Private WS valid token + welcome", msg.get("event") == "connected"))
    except Exception as e:
        ws_ok.append(ok("Private WS valid token", False, str(e)))

    # Private WS — invalid JWT (expect close/rejection)
    try:
        async with websockets.connect(f"{WS_BASE}/private?token=bad.token.here") as ws:
            await asyncio.wait_for(ws.recv(), timeout=3)
            ws_ok.append(ok("Private WS invalid token rejected", False, "Connection NOT closed"))
    except Exception:
        ws_ok.append(ok("Private WS invalid token rejected", True))

asyncio.run(test_ws())


# ─────────────────────────────────────────────────────────
# SUMMARY
# ─────────────────────────────────────────────────────────
section("SUMMARY")
passed = sum(1 for _, p in results if p)
total = len(results)
failed = total - passed

print(f"\n  Total  : {total}")
print(f"  Passed : {passed}")
print(f"  Failed : {failed}")
print(f"  Score  : {passed}/{total}  ({100*passed//total if total else 0}%)\n")

if PASS_ALL:
    print("  ALL TESTS PASSED")
else:
    print("  SOME TESTS FAILED - see FAIL lines above")
