from sqlalchemy.orm import Session
from .models import TodoORM
from todo_api.domain.todo import Todo

class TodoRepository:
    def __init__(self, db: Session):
        self.db = db

    def add(self, todo: Todo) -> Todo:
        db_todo = TodoORM(title=todo.title, description=todo.description)
        self.db.add(db_todo)
        self.db.commit()
        self.db.refresh(db_todo)
        return Todo(id=db_todo.id, title=db_todo.title, description=db_todo.description)

    def get_all(self) -> list[Todo]:
        todos = self.db.query(TodoORM).all()
        return [Todo(id=t.id, title=t.title, description=t.description) for t in todos]

    def get_by_id(self, todo_id: int) -> Todo | None:
        todo = self.db.query(TodoORM).filter(TodoORM.id == todo_id).first()
        if not todo:
            return None
        return Todo(id=todo.id, title=todo.title, description=todo.description)
