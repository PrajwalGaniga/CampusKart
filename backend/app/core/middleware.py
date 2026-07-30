"""
Custom middleware stack:
  1. RequestIDMiddleware  — injects X-Request-ID header
  2. TimingMiddleware     — logs execution time per request
  3. LoggingMiddleware    — structured request/response logging
"""

import logging
import time
import uuid
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import Response

logger = logging.getLogger(__name__)


class RequestIDMiddleware(BaseHTTPMiddleware):
    """Attach a unique request ID to every request and response."""

    async def dispatch(self, request: Request, call_next) -> Response:
        request_id = str(uuid.uuid4())
        request.state.request_id = request_id
        response = await call_next(request)
        response.headers["X-Request-ID"] = request_id
        return response


class TimingMiddleware(BaseHTTPMiddleware):
    """Measure and expose request execution time."""

    async def dispatch(self, request: Request, call_next) -> Response:
        start = time.perf_counter()
        response = await call_next(request)
        elapsed_ms = (time.perf_counter() - start) * 1000
        response.headers["X-Process-Time-Ms"] = f"{elapsed_ms:.2f}"
        return response


class LoggingMiddleware(BaseHTTPMiddleware):
    """
    Log every inbound request and outbound response including:
      - HTTP method & path
      - Status code
      - Execution time
      - Request ID
    """

    async def dispatch(self, request: Request, call_next) -> Response:
        start = time.perf_counter()
        request_id = getattr(request.state, "request_id", "-")

        logger.info(
            f"[REQ] {request.method} {request.url.path} | id={request_id}"
        )

        try:
            response = await call_next(request)
        except Exception as exc:
            logger.error(
                f"[ERR] {request.method} {request.url.path} | id={request_id} | {exc}",
                exc_info=exc,
            )
            raise

        elapsed_ms = (time.perf_counter() - start) * 1000
        logger.info(
            f"[RES] {request.method} {request.url.path} "
            f"→ {response.status_code} | {elapsed_ms:.2f}ms | id={request_id}"
        )
        return response
