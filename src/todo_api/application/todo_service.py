from todo_api.domain.todo import Todo
from todo_api.infrastructure.repositories import TodoRepository

class TodoService:
    def __init__(self, repo: TodoRepository):
        self.repo = repo

    def create_todo(self, title: str, description: str) -> Todo:
        todo = Todo(id=None, title=title, description=description)
        return self.repo.add(todo)

    def get_todos(self) -> list[Todo]:
        return self.repo.get_all()

    def get_todo(self, todo_id: int) -> Todo | None:
        return self.repo.get_by_id(todo_id)
