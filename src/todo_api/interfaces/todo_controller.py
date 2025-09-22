from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from todo_api.infrastructure.database import SessionLocal
from todo_api.application.todo_service import TodoService
from todo_api.infrastructure.repositories import TodoRepository
from todo_api.domain.todo import Todo

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/todos/", response_model=Todo, tags=["Todos"])
def create_todo(title: str, description: str, db: Session = Depends(get_db)):
    service = TodoService(TodoRepository(db))
    return service.create_todo(title, description)

@router.get("/todos/", response_model=list[Todo], tags=["Todos"])
def read_todos(db: Session = Depends(get_db)):
    service = TodoService(TodoRepository(db))
    return service.get_todos()

@router.get("/todos/{todo_id}", response_model=Todo, tags=["Todos"])
def read_todo(todo_id: int, db: Session = Depends(get_db)):
    service = TodoService(TodoRepository(db))
    todo = service.get_todo(todo_id)
    if not todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    return todo
