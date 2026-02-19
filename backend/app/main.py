from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from starlette.middleware.base import BaseHTTPMiddleware

from app.logging_config import configure_logging, get_logger
from app.models import Asset, Insight, HealthResponse
from app.services import get_assets, calculate_insights

configure_logging()
logger = get_logger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("startup", version="1.0.0")
    yield
    logger.info("shutdown")


app = FastAPI(title="Portfolio API", version="1.0.0", lifespan=lifespan)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # TODO: Configure for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class RequestLoggingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        response = await call_next(request)
        logger.info(
            "request",
            method=request.method,
            path=request.url.path,
            status_code=response.status_code,
        )
        return response


app.add_middleware(RequestLoggingMiddleware)


@app.get("/health", response_model=HealthResponse)
def health_check():
    return HealthResponse(status="healthy", version="1.0.0")


@app.get("/assets", response_model=list[Asset])
def list_assets():
    return get_assets()


@app.get("/insights", response_model=list[Insight])
def list_insights():
    assets = get_assets()
    return calculate_insights(assets)
