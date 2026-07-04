---
name: session-start
description: Start or resume a coding-agent session by inspecting the repository state before making changes. Use when beginning work, after a context switch, after user says something may be overwritten, or before touching files in an unfamiliar/dirty workspace.
---

# Session Start

## Workflow

1. Confirm the working directory with `pwd`.
2. Inspect Git state with `git status --short --branch`.
3. Read recent context with `git log --oneline -5`.
4. If the task touches configuration, read the relevant root guidance first: `AGENTS.md`, `README.md`, and nearby config files.
5. If the tree is dirty, classify changes before editing:
   - changes clearly related to the current request
   - pre-existing user changes to avoid overwriting
   - generated or runtime files to ignore
   - untracked files that may need explicit handling
6. Name the next action and any risk before modifying files.

## Output

Report briefly:

- current path
- current branch and sync state
- dirty files or "clean"
- relevant existing context found
- next intended step

Do not stage, commit, stash, delete, or overwrite files during this skill.
