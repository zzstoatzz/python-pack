from typing import Callable, Literal, get_origin

from pydantic import TypeAdapter


def parse_as[T](
    type_: type[T],
    data: object,
    mode: Literal["python", "json", "strings"] = "python",
) -> T:
    """Parse a given data structure as a Pydantic model via `TypeAdapter`.

    Read more about `TypeAdapter` [here](https://docs.pydantic.dev/latest/concepts/type_adapter/).

    Args:
        type_: The type to parse the data as.
        data: The data to be parsed.
        mode: The mode to use for parsing, either `python`, `json`, or `strings`.
            Defaults to `python`, where `data` should be a Python object (e.g. `dict`).

    Returns:
        The parsed `data` as the given `type_`.


    Example:
        ```python
        from python_pack.utils import parse_as
        from pydantic import BaseModel

        class ExampleModel(BaseModel):
            name: str

        # parsing python objects
        parsed = parse_as(list[ExampleModel], [{"name": "Marvin"}, {"name": "Arthur"}])
        assert isinstance(parsed, list)
        assert parsed[0].name == "Marvin"

        # parsing json strings
        parsed = parse_as(
            list[ExampleModel],
            '[{"name": "Marvin"}, {"name": "Arthur"}]',
            mode="json"
        )
        assert all(isinstance(item, ExampleModel) for item in parsed)
        assert parsed[0].name == "Marvin"
        assert parsed[1].name == "Arthur"
        ```

    """
    adapter = TypeAdapter(type_)

    if get_origin(type_) is list and isinstance(data, dict):
        data = next(iter(data.values()))

    parser: Callable[[object], T] = getattr(adapter, f"validate_{mode}")

    return parser(data)
