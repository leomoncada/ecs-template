"""
Structured logging configuration (JSON to stdout) for ECS/CloudWatch and local dev.
"""
import os

import structlog


def configure_logging() -> None:
    json_logs = os.getenv("LOG_JSON", "true").lower() in ("1", "true", "yes")
    shared = [
        structlog.contextvars.merge_contextvars,
        structlog.processors.add_log_level,
        structlog.processors.TimeStamper(fmt="iso", utc=True),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
    ]
    renderer = (
        structlog.processors.JSONRenderer()
        if json_logs
        else structlog.dev.ConsoleRenderer(colors=True)
    )
    structlog.configure(
        processors=shared + [renderer],
        context_class=dict,
        logger_factory=structlog.PrintLoggerFactory(),
        cache_logger_on_first_use=True,
    )


def get_logger(*args: str, **initial_values: object):
    return structlog.get_logger(*args, **initial_values)
