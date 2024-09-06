# want a python environment that just works?
here you go!

```
gh repo clone zzstoatzz/python-pack
cd python-pack
make clean
make dev
source .venv/bin/activate
pytest

# and if you have an OPENAI_API_KEY set, you can run the todo app example:
make example
```