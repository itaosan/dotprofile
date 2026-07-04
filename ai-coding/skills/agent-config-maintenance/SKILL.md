---
name: agent-config-maintenance
description: Maintain shared Claude Code and Codex agent configuration under ai-coding. Use when editing AGENTS.md, README, install.sh, skills, agents, hooks, rules, Codex config, Claude settings, or shared skill layout.
---

# Agent Config Maintenance

## Layout Rules

- Keep `ai-coding/AGENTS.md` as a short pointer for durable shared behavior.
- Put reusable procedures in `ai-coding/skills/<skill-name>/SKILL.md`.
- Put Claude Code deterministic enforcement in `ai-coding/claude/hooks/`, `ai-coding/claude/rules/`, and `ai-coding/claude/settings.json`.
- Put portable Codex settings in `ai-coding/codex/config.toml`; keep runtime paths, trusted projects, local marketplace state, directory trust, generated local MCP runtime paths, and notification command paths in each user's local `~/.codex/config.toml`.
- Share Skills from one source:
  - Claude Code reads `ai-coding/skills` via `~/.claude/skills`
  - Codex reads each skill via `~/.agents/skills/<skill-name>`

## Change Workflow

1. Use `session-start` before editing.
2. Decide whether the change belongs in AGENTS, a Skill, a hook, a rule, or a config file.
3. Prefer Skills for workflows that should work in both Claude Code and Codex.
4. Keep platform-specific tool names out of shared Skills unless the skill explicitly handles both paths.
5. If you add or move a deployed path, update `ai-coding/install.sh`.
6. If the user-facing structure changes, update `README.md`.
7. Validate changed surfaces with `completion-check`.

## Skill Authoring Rules

- Use `name` and `description` frontmatter only.
- Put trigger conditions in `description`; the body is loaded only after the skill triggers.
- Keep `SKILL.md` concise and move large details to `references/` only when needed.
- Avoid extra README or changelog files inside skill folders.
- Use `agents/openai.yaml` only when Codex App UI metadata, invocation policy, or tool dependencies are useful.
- Prefer instruction-only Skills unless deterministic scripts are clearly useful and portable.

## Safety

Do not remove or overwrite user-local Skills, config, or dirty repository changes unless the user explicitly asks.
