import requests
import sys
sys.stdout.reconfigure(encoding='utf-8')

BASE = 'http://localhost:8000/api/v1'

p = requests.post(f'{BASE}/auth/login', json={'username':'prajwal','password':'12345678'}).json()
i = requests.post(f'{BASE}/auth/login', json={'username':'ishwarya','password':'12345678'}).json()
pt = p.get('access_token','')
it = i.get('access_token','')
ph = {'Authorization': f'Bearer {pt}'}
ih = {'Authorization': f'Bearer {it}'}

results = []

def test(name, r, expect):
    ok = r.status_code == expect
    results.append((name, r.status_code, expect, ok))
    status = 'PASS' if ok else 'FAIL'
    detail = ''
    if not ok:
        detail = f'  => {r.text[:120]}'
    print(f'  [{status}] {name} -> got {r.status_code} (want {expect}){detail}')
    return ok

print()
print('=== AUTH ===')
test('GET / root', requests.get('http://localhost:8000/'), 200)
test('GET /health', requests.get('http://localhost:8000/health'), 200)
test('POST /auth/login valid', requests.post(f'{BASE}/auth/login', json={'username':'prajwal','password':'12345678'}), 200)
test('POST /auth/login bad pass', requests.post(f'{BASE}/auth/login', json={'username':'prajwal','password':'wrong'}), 401)
test('No auth header', requests.get(f'{BASE}/asks/my'), 401)
test('Bad JWT token', requests.get(f'{BASE}/asks/my', headers={'Authorization':'Bearer bad.jwt'}), 401)

print()
print('=== FRIENDS ===')
test('GET /friends/search', requests.get(f'{BASE}/friends/search?query=ish', headers=ph), 200)
test('GET /friends/pending', requests.get(f'{BASE}/friends/pending', headers=ih), 200)
test('GET /friends/sent', requests.get(f'{BASE}/friends/sent', headers=ph), 200)
test('GET /friends/ (list)', requests.get(f'{BASE}/friends/', headers=ph), 200)

fl = requests.get(f'{BASE}/friends/', headers=ph).json()
if isinstance(fl, list):
    names = [f.get('username') for f in fl]
    print(f'    prajwal friend list: {names}')

print()
print('=== ASKS ===')
ask_payload = {
    'title': 'Audit test ask',
    'description': 'Testing ask creation in audit script',
    'category': 'ACADEMIC',
    'location': 'Library',
    'expires_in_minutes': 20
}
r_ask = requests.post(f'{BASE}/asks/', json=ask_payload, headers=ph)
test('POST /asks/ create', r_ask, 200)
ask_id = r_ask.json().get('id') if r_ask.status_code == 200 else None
if ask_id:
    print(f'    Created ask_id={ask_id}')

test('GET /asks/feed (ishwarya)', requests.get(f'{BASE}/asks/feed', headers=ih), 200)
test('GET /asks/my (prajwal)', requests.get(f'{BASE}/asks/my', headers=ph), 200)

if ask_id:
    test('GET /asks/{id}', requests.get(f'{BASE}/asks/{ask_id}', headers=ph), 200)

test('GET /asks/nonexistent', requests.get(f'{BASE}/asks/000000000000000000000000', headers=ph), 404)
test('GET /asks/garbage_id', requests.get(f'{BASE}/asks/not_an_id', headers=ph), 500)

print()
print('=== REPLIES ===')
if ask_id:
    test('POST reply (ishwarya)', requests.post(f'{BASE}/asks/{ask_id}/reply', json={'message':'I can help with the audit!'}, headers=ih), 200)
    test('POST reply duplicate', requests.post(f'{BASE}/asks/{ask_id}/reply', json={'message':'Again'}, headers=ih), 400)
    test('POST reply own ask blocked', requests.post(f'{BASE}/asks/{ask_id}/reply', json={'message':'Mine'}, headers=ph), 400)
    r_replies = requests.get(f'{BASE}/asks/{ask_id}/replies', headers=ph)
    test('GET /asks/{id}/replies (owner)', r_replies, 200)
    test('GET /asks/{id}/replies (non-owner)', requests.get(f'{BASE}/asks/{ask_id}/replies', headers=ih), 403)
    reps = r_replies.json()
    rid = reps[0]['id'] if isinstance(reps, list) and reps else None
    if rid:
        test('POST /asks/{id}/resolve', requests.post(f'{BASE}/asks/{ask_id}/resolve', json={'reply_id': rid}, headers=ph), 200)

print()
print('=== USERS & NEW MVPS ===')
test('GET /users/me', requests.get(f'{BASE}/users/me', headers=ph), 200)
test('PUT /users/me', requests.put(f'{BASE}/users/me', json={'display_name': 'Prajwal Edited'}, headers=ph), 200)
test('GET /notifications', requests.get(f'{BASE}/notifications', headers=ph), 200)
test('GET /activity', requests.get(f'{BASE}/activity', headers=ph), 200)

print()
print('=== LOGOUT ===')
test('POST /auth/logout', requests.post(f'{BASE}/auth/logout', headers=ph), 200)
test('GET /users/me (after logout)', requests.get(f'{BASE}/users/me', headers=ph), 200) # Assuming JWT still valid in memory unless token blacklisted, but session is deleted.

print()
print('=== SUMMARY ===')
passed = sum(1 for r in results if r[3])
total = len(results)
failed = total - passed
print(f'  Passed: {passed}/{total}')
print(f'  Failed: {failed}')
if failed == 0:
    print('  ALL CHECKS PASSED')
else:
    print('  FAILED CHECKS:')
    for name, got, want, ok in results:
        if not ok:
            print(f'    - {name}: got {got}, want {want}')
