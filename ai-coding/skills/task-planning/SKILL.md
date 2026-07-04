---
name: task-planning
description: Plan non-trivial code, configuration, documentation, or workflow changes before implementation. Use when the user asks for a plan, when requirements are ambiguous, when multiple files or tools are involved, or when approval is needed before editing.
---

# Task Planning

## Workflow

1. Start from the current repository state. Use `session-start` first if the workspace state is unknown.
2. Restate the goal in one sentence.
3. Identify constraints from `AGENTS.md`, README, existing scripts, tool configs, and user instructions.
4. Ask one concise question if a missing decision can materially change the work. Otherwise make a conservative assumption and state it.
5. Propose 2-3 approaches only when there is a real tradeoff.
6. Recommend one approach and explain why.
7. Present an implementation plan with:
   - files to create or modify
   - behavior or workflow change
   - documentation updates
   - verification commands or manual checks
   - known risks or deferred items
8. Wait for approval before editing unless the user's instruction explicitly requests immediate execution.

## Plan Shape

Use a short checklist for small tasks. Use grouped phases for larger tasks.

Each phase should be independently reviewable and should avoid mixing unrelated refactors with the requested change.

## Scope Rules

- Keep durable instructions small and move reusable procedures into Skills.
- Prefer common Claude Code / Codex Skills when a workflow should work across both.
- Keep Claude-only hooks/rules and Codex-only config separate from shared instructions.
- Do not introduce a fallback path unless the user explicitly wants one; stop with a clear log or report instead.
