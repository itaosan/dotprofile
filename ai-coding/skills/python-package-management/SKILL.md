---
name: python-package-management
description: Use when working with Python dependencies, virtual environments, Python scripts, pyproject.toml, uv.lock, requirements files, or commands that would otherwise use pip, pip3, or python -m pip.
---

# Python Package Management

Use `uv` for Python package management and script execution.

## Rules

- Do not use `pip`, `pip3`, or `python -m pip`.
- Use `uv add <package>` for runtime dependencies.
- Use `uv add --dev <package>` for development dependencies.
- Use `uv remove <package>` to remove dependencies.
- Use `uv sync` to install from the lockfile.
- Use `uv run <command>` or `uv run python <script>` to run Python in the project environment.
- For one-off tools or scripts, use `uvx <tool>` or `uv run --with <package> <command>`.
- If dependencies change, update the lockfile and relevant documentation.
- If a hook or permission blocks a Python package command, stop and report it instead of trying another installer.

## Checks

Before reporting completion after Python dependency changes:

1. Inspect changed dependency files.
2. Confirm `uv.lock` is updated when applicable.
3. Run the relevant tests or import checks with `uv run`.
4. Report any environment assumptions, especially on Windows, WSL, or CI.
