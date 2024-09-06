# /// script
# dependencies = ["marvin"]
# ///

from marvin.beta.applications import Application
from pydantic import BaseModel, Field


class TodoState(BaseModel):
    items: list[str] = Field(default_factory=list)


if __name__ == "__main__":
    with Application(
        name="todo-app",
        description="A simple todo app",
        instructions="Ask me before running any commands on the host machine. be like TARS from interstellar",
        state=TodoState(),
        model="gpt-4o",
    ) as app:
        app.chat(initial_message="what do i need to do today?")
