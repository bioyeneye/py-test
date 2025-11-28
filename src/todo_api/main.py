from fastapi import FastAPI
from src.todo_api.infrastructure.database import Base, engine
from src.todo_api.infrastructure import models
from src.todo_api.interfaces.todo_controller import router as todo_router

Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Todo API",
    description="Todo",
    version="1.0.0",
    docs_url="/docs",       # Swagger UI
    redoc_url="/redoc",     # ReDoc UI
    openapi_url="/openapi.json"  # OpenAPI schema
)

@app.get("/")
def read_root():
    return {"message": "Todo API", "version": "1.0.0"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}

app.include_router(todo_router)