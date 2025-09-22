from dataclasses import dataclass

@dataclass
class Todo:
    id: int | None
    title: str
    description: str
