.DEFAULT_GOAL := install
.PHONY: all install clean test dev publish example

UV := $(shell which uv)
UV_VERSION := $(shell $(UV) --version | cut -d ' ' -f 2)
VENV_DIR := .venv
REQUIREMENTS := requirements.txt
DEV_REQUIREMENTS := requirements-dev.txt

$(info Using uv @ $(UV))
$(info - version: $(UV_VERSION))

all: install test

.bookkeeping/uv-$(UV_VERSION):
	@if command -v uv >/dev/null 2>&1; then \
		echo "(uv already installed)"; \
	else \
		read -p "uv is not installed. Do you want to install it? (y/N) " answer; \
		if [ "$$answer" = "y" ] || [ "$$answer" = "Y" ]; then \
			mkdir -p .bookkeeping; \
			curl -LsSf https://astral.sh/uv/install.sh | sh; \
			touch $@; \
		else \
			echo "Installation cancelled. Please install uv manually to proceed."; \
			exit 1; \
		fi; \
	fi

$(VENV_DIR): .bookkeeping/uv-$(UV_VERSION)
	uv venv $(VENV_DIR)

$(REQUIREMENTS): pyproject.toml
	uv pip compile pyproject.toml -o $(REQUIREMENTS)

$(DEV_REQUIREMENTS): pyproject.toml
	uv pip compile --extra dev pyproject.toml -o $(DEV_REQUIREMENTS)

dev: $(VENV_DIR) $(DEV_REQUIREMENTS)
	uv pip sync $(DEV_REQUIREMENTS)
	uv pip install -e .[dev]
	@echo "ᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖ"
	@echo "Virtual environment is ready."
	@echo ""
	@echo "To activate, run:"
	@echo "source $(VENV_DIR)/bin/activate"
	@echo "ᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖ"

install: $(VENV_DIR) $(REQUIREMENTS)
	uv build
	uv pip install dist/*.whl

publish: install
	uvx twine upload dist/*

clean:
	rm -rf .bookkeeping/ $(VENV_DIR) $(REQUIREMENTS) $(DEV_REQUIREMENTS) dist/

test:
	uv run pytest

example:
	@if [ -z "$$OPENAI_API_KEY" ]; then \
		echo "ᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖ"; \
		echo "Error: OPENAI_API_KEY is not set!"; \
		echo "Please set your OpenAI API key to run this example."; \
		echo "You can do this by running:"; \
		echo "export OPENAI_API_KEY='your-api-key-here'"; \
		echo "ᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖᨖ"; \
		exit 1; \
	fi
	uv run examples/todo/todo_app.py