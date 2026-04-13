from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import HTMLResponse
from pathlib import Path

from app.models.database import init_db
from app.routers import library, reader, ai

app = FastAPI(title="AI Book Reader")

# Mount static files
static_dir = Path(__file__).parent / "static"
app.mount("/static", StaticFiles(directory=str(static_dir)), name="static")

# Include routers
app.include_router(library.router)
app.include_router(reader.router)
app.include_router(ai.router)


@app.on_event("startup")
def startup():
    init_db()


@app.get("/", response_class=HTMLResponse)
def index():
    template = Path(__file__).parent / "templates" / "index.html"
    return template.read_text()
