---
name: project-config-sync
description: Set up or repair single-source Claude Code and Codex instructions inside one project, with AGENTS.md as the real file, CLAUDE.md as an @AGENTS.md import, and project skills shared from .agents/skills. Use when a project must support both tools, when CLAUDE.md and AGENTS.md drift apart, or when project skills need sharing.
---

# Project Config Sync

Make one project readable by Claude Code and Codex from a single source, without duplicating instructions.

## Target Layout

| Path | Role |
|---|---|
| `AGENTS.md` | Real instruction file; Codex reads it directly |
| `CLAUDE.md` | Starts with an `@AGENTS.md` import line; Claude-only notes go below it |
| `.agents/skills/<name>/` | Real project skill definitions (Codex project scope) |
| `.claude/skills` | Relative symlink to `../.agents/skills` for Claude Code |

Claude Code expands `@AGENTS.md` at session start. Imports resolve relative to the importing file and may nest up to four hops. On Windows, prefer the import form over a `CLAUDE.md` symlink because symlinks need Developer Mode or administrator rights.

## Workflow

1. Use `session-start`, confirm the project root, and check the current state of `AGENTS.md`, `CLAUDE.md`, `.claude/skills`, and `.agents/skills`.
2. Apply the matching case:
   - Neither instruction file exists: create `AGENTS.md` with the shared project guidance, then create `CLAUDE.md` containing only `@AGENTS.md`.
   - Only `CLAUDE.md` exists: move its shared content into `AGENTS.md` and rewrite `CLAUDE.md` as the `@AGENTS.md` line plus any Claude-only notes. Show the planned diff before writing.
   - Only `AGENTS.md` exists: create `CLAUDE.md` containing `@AGENTS.md`.
   - Both exist with different content: show the diff and let the user decide the merge. Never merge silently.
3. Keep tool-neutral guidance in `AGENTS.md`; keep Claude-specific rules in `CLAUDE.md` below the import line.
4. Share project skills only when the project has them:
   - Keep skill directories in `.agents/skills/<name>/` as the single source.
   - Create the link with `mkdir -p .claude && ln -s ../.agents/skills .claude/skills`.
   - On Windows Git Bash, export `MSYS=winsymlinks:nativestrict` first; symlink creation needs Developer Mode or administrator rights.
   - If `.claude/skills` already exists as a real directory, move its skills into `.agents/skills/` before linking, with user approval.
   - If the symlink cannot be created, stop and report the environment issue; do not fall back to copying.
5. Before committing generated files or symlinks, confirm the project policy with the user; on Windows also check `git config core.symlinks`.

## Verify

- `CLAUDE.md` contains `@AGENTS.md` outside any backtick code span, otherwise the import is skipped.
- `.claude/skills` resolves to `.agents/skills` (`ls -la .claude`, `readlink .claude/skills`).
- In the next Claude Code session, `/context` lists `CLAUDE.md` under Memory files.
- Codex picks up `AGENTS.md` and `.agents/skills/<name>` from the repository without extra steps.

## Safety

- Never overwrite or merge existing `AGENTS.md` / `CLAUDE.md` content without showing the diff and getting approval.
- Do not replace a failed symlink with a file copy; duplicated skills drift apart.
- Leave user-local files such as `CLAUDE.local.md` and `.claude/settings.local.json` untouched.
