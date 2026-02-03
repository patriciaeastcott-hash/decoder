# CLAUDE.md - AI Assistant Guide for Decoder

This document provides comprehensive guidance for AI assistants working with the decoder codebase.

## Project Overview

**Project Name:** decoder
**Language:** Python
**Status:** Early development phase (skeleton project)

The decoder project is a Python-based utility. As development progresses, this document will be updated to reflect the evolving architecture and conventions.

## Repository Structure

```
decoder/
├── .git/                   # Git repository metadata
├── .gitignore              # Comprehensive Python gitignore
├── CLAUDE.md               # This file - AI assistant guide
└── README.md               # Project documentation
```

### Expected Structure (as project develops)

```
decoder/
├── src/
│   └── decoder/
│       ├── __init__.py     # Package initialization
│       ├── __main__.py     # CLI entry point
│       └── core/           # Core functionality
├── tests/
│   ├── __init__.py
│   ├── conftest.py         # pytest fixtures
│   └── test_*.py           # Test modules
├── docs/                   # Documentation (Sphinx/mkdocs)
├── pyproject.toml          # Project configuration (PEP 621)
├── requirements.txt        # Dependencies (or use pyproject.toml)
└── ...
```

## Technology Stack

### Core
- **Language:** Python 3.x
- **Package Format:** Modern Python packaging (pyproject.toml recommended)

### Development Tools (prepared via .gitignore)
- **Package Managers:** pip, Poetry, pipenv, pdm, UV, pixi
- **Type Checking:** mypy, Pyre, pytype
- **Linting/Formatting:** Ruff, pylint
- **Testing:** pytest, tox, nox, coverage
- **Documentation:** Sphinx, mkdocs

### Supported Frameworks (based on .gitignore coverage)
- Web: Django, Flask
- Data: Jupyter Notebook, IPython
- Scraping: Scrapy
- Task Queues: Celery

## Development Setup

### Creating a Virtual Environment

```bash
# Using venv (standard library)
python -m venv .venv
source .venv/bin/activate  # Linux/macOS
# .venv\Scripts\activate   # Windows

# Using UV (recommended for speed)
uv venv
source .venv/bin/activate
```

### Installing Dependencies

```bash
# When requirements.txt exists:
pip install -r requirements.txt

# When pyproject.toml exists:
pip install -e ".[dev]"

# Using UV:
uv pip install -e ".[dev]"
```

## Code Style and Conventions

### Python Style Guidelines

1. **Follow PEP 8** - Standard Python style guide
2. **Use type hints** - Add type annotations for function signatures
3. **Write docstrings** - Use Google or NumPy style docstrings
4. **Keep functions focused** - Single responsibility principle

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Modules | lowercase_snake | `decoder_utils.py` |
| Classes | PascalCase | `DataDecoder` |
| Functions | lowercase_snake | `decode_message()` |
| Constants | UPPERCASE_SNAKE | `MAX_BUFFER_SIZE` |
| Private | leading underscore | `_internal_helper()` |

### Import Order

```python
# Standard library
import os
import sys
from pathlib import Path

# Third-party packages
import requests
from pydantic import BaseModel

# Local application
from decoder.core import utils
from decoder.models import Message
```

## Testing Guidelines

### Test Structure

```python
# tests/test_example.py
import pytest
from decoder.core import decode

class TestDecoder:
    """Tests for decoder functionality."""

    def test_basic_decode(self):
        """Test basic decoding operation."""
        result = decode("encoded_data")
        assert result == "expected_output"

    @pytest.mark.parametrize("input,expected", [
        ("input1", "output1"),
        ("input2", "output2"),
    ])
    def test_decode_variations(self, input, expected):
        """Test multiple decode scenarios."""
        assert decode(input) == expected
```

### Running Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=decoder --cov-report=html

# Run specific test file
pytest tests/test_core.py

# Run tests matching pattern
pytest -k "decode"
```

## Git Workflow

### Branch Naming

- Feature branches: `feature/description`
- Bug fixes: `fix/description`
- Claude AI branches: `claude/claude-md-*`

### Commit Messages

Follow conventional commits format:

```
type(scope): short description

[optional body]

[optional footer]
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Example:
```
feat(decoder): add base64 decoding support

Implements Base64 decoding with proper padding handling.
Includes both standard and URL-safe variants.
```

## AI Assistant Guidelines

### When Working on This Codebase

1. **Read before writing** - Always read existing files before modifying them
2. **Preserve patterns** - Follow existing code conventions and patterns
3. **Minimal changes** - Make focused changes; avoid over-engineering
4. **Test coverage** - Add tests for new functionality
5. **Type safety** - Include type hints for new code

### Common Tasks

#### Adding a New Module

1. Create the module in `src/decoder/` (or appropriate location)
2. Add `__init__.py` exports if needed
3. Create corresponding test file in `tests/`
4. Update any relevant documentation

#### Adding Dependencies

1. Add to `pyproject.toml` under `[project.dependencies]` or `[project.optional-dependencies]`
2. Or add to `requirements.txt` with version pinning
3. Document why the dependency is needed

#### Debugging

```bash
# Run with verbose output
python -m decoder -v

# Run with Python debugger
python -m pdb -m decoder

# Run specific module
python -m decoder.module_name
```

### Security Considerations

- Never commit secrets or credentials
- Use environment variables for sensitive configuration
- Validate and sanitize all external input
- Be cautious with pickle/eval/exec operations

## Configuration Files

### pyproject.toml (recommended)

```toml
[project]
name = "decoder"
version = "0.1.0"
description = "A decoding utility"
requires-python = ">=3.9"
dependencies = []

[project.optional-dependencies]
dev = [
    "pytest>=7.0",
    "pytest-cov>=4.0",
    "mypy>=1.0",
    "ruff>=0.1",
]

[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "-v"

[tool.mypy]
strict = true

[tool.ruff]
line-length = 88
select = ["E", "F", "I", "N", "W"]
```

## Useful Commands Reference

| Task | Command |
|------|---------|
| Run tests | `pytest` |
| Type check | `mypy src/` |
| Lint | `ruff check .` |
| Format | `ruff format .` |
| Build package | `python -m build` |
| Install dev | `pip install -e ".[dev]"` |

## Troubleshooting

### Common Issues

**Import errors:**
- Ensure the package is installed: `pip install -e .`
- Check `PYTHONPATH` includes the project root

**Type checking errors:**
- Install type stubs: `pip install types-<package>`
- Add `# type: ignore` for unavoidable issues (sparingly)

**Test failures:**
- Run with `-v` for verbose output
- Use `--pdb` to drop into debugger on failure

---

*Last updated: 2026-02-03*
*This document should be updated as the project evolves.*
