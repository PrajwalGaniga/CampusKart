"""
Global exception handlers & consistent error response format.

Every error returns:
{
    "success": false,
    "message": "...",
    "error": "...",
    "timestamp": "..."
}
"""

import logging
from datetime import datetime, timezone
from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException

logger = logging.getLogger(__name__)


def _error_body(message: str, error: str) -> dict:
    return {
        "success": False,
        "message": message,
        "error": error,
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }


def register_exception_handlers(app: FastAPI) -> None:

    @app.exception_handler(StarletteHTTPException)
    async def http_exception_handler(request: Request, exc: StarletteHTTPException):
        status_messages = {
            400: "Bad request",
            401: "Unauthorized — please log in",
            403: "Forbidden — you do not have permission",
            404: "Resource not found",
            409: "Conflict — resource already exists or state mismatch",
            422: "Validation error",
            500: "Internal server error",
        }
        message = status_messages.get(exc.status_code, "An error occurred")
        logger.warning(
            f"HTTP {exc.status_code} on {request.method} {request.url.path} — {exc.detail}"
        )
        return JSONResponse(
            status_code=exc.status_code,
            content=_error_body(message, str(exc.detail)),
        )

    @app.exception_handler(RequestValidationError)
    async def validation_exception_handler(request: Request, exc: RequestValidationError):
        errors = exc.errors()
        field_errors = "; ".join(
            f"{'.'.join(str(loc) for loc in e['loc'])}: {e['msg']}"
            for e in errors
        )
        logger.warning(
            f"Validation error on {request.method} {request.url.path} — {field_errors}"
        )
        return JSONResponse(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            content=_error_body("Request validation failed", field_errors),
        )

    @app.exception_handler(Exception)
    async def generic_exception_handler(request: Request, exc: Exception):
        logger.error(
            f"Unhandled exception on {request.method} {request.url.path}",
            exc_info=exc,
        )
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content=_error_body("Internal server error", "An unexpected error occurred"),
        )
