## CampusPulse Backend (Version 1.0)
backend + frontend

A high-performance FastAPI backend for the CampusPulse application.

## Architecture

- **Framework**: FastAPI
- **Database**: MongoDB (motor + beanie ODM)
- **WebSockets**: Built-in FastAPI websockets for realtime updates.
- **Authentication**: JWT based stateless authentication with session invalidation.

## Core Modules

- `Users`: Profile management.
- `Auth`: Registration, Login, Logout.
- `Friends`: Sending, accepting, rejecting, tracking friends.
- `Asks`: Global feed and personal tasks, TTL indexing.
- `Replies`: Limit 5 replies per ask with atomic constraints.
- `Notifications`: Realtime and persistent alerts.
- `Activity Logs`: Tracking user actions.
- `WebSockets`: Live presence (Online/Offline) and broadcasting.

## Development Setup

1. **Environment Variables**:
   Copy `.env.example` to `.env` and fill in the values.
   ```bash
   cp backend/.env.example backend/.env
   ```

2. **Run MongoDB via Docker**:
   ```bash
   docker-compose up -d
   ```

3. **Install Dependencies**:
   ```bash
   cd backend
   python -m venv venv
   source venv/bin/activate  # On Windows: .\venv\Scripts\activate
   pip install -r requirements.txt
   ```

4. **Start Server**:
   ```bash
   uvicorn app.main:app --reload
   ```
   The API will be available at `http://localhost:8000`.

## Testing

A full automated integration suite is available in the `tests/` directory.

```bash
# Ensure server is running, then execute:
python tests/audit.py
```

## Docker Production Build

```bash
docker build -t campuspulse-backend .
docker run -p 8000:8000 --env-file .env campuspulse-backend
```

## WebSockets
- **Public Feed**: `ws://localhost:8000/ws/public`
- **Private Stream**: `ws://localhost:8000/ws/private?token=YOUR_JWT`
