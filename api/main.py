from contextlib import asynccontextmanager
from typing import AsyncIterator

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from api.database import Base, engine
from api.routers import categories, images, items, lists, reminders


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    """Create DB tables on startup; skip gracefully if DB is unavailable."""
    try:
        Base.metadata.create_all(bind=engine)
    except Exception as exc:
        print(f"[startup] Could not create tables: {exc}")
    yield


app = FastAPI(
    title="Smart Grocery API",
    description="Backend for the Smart Grocery iOS app",
    version="0.1.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(items.router,      prefix="/items",      tags=["items"])
app.include_router(categories.router, prefix="/categories", tags=["categories"])
app.include_router(lists.router,      prefix="/lists",      tags=["lists"])
app.include_router(reminders.router,  prefix="/reminders",  tags=["reminders"])
app.include_router(images.router,     prefix="/images",     tags=["images"])


@app.get("/health")
def health():
    return {"status": "ok"}
