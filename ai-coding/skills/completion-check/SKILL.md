---
name: completion-check
description: Verify work before reporting completion, committing, pushing, or opening a PR. Use after code, documentation, configuration, skill, hook, or installer changes, especially when Windows, Claude Code, Codex CLI, or Codex App behavior may differ.
---

# Completion Check

## Workflow

1. Re-read the user's latest request and confirm the work answers it.
2. Inspect the final diff with `git diff --stat` and targeted `git diff -- <paths>`.
3. Check for unrelated or pre-existing changes and explicitly separate them from the current work.
4. Choose verification that fits the changed surface:
   - shell scripts: `bash -n <script>`
   - JSON: parse with an available runtime such as Node.js
   - Markdown Skills: run the skill validator when available
   - install scripts: run against temporary HOME directories
   - web UI: use the built-in browser tools or another available browser check
   - unknown platform behavior: report the uncertainty instead of pretending a fixed script proves it
5. Run the selected checks freshly.
6. Read the outputs and exit codes.
7. Fix failures or report the exact blocker.
8. Only then report completion, including what was verified and what was not.

## Reporting

Keep the final report short and specific:

- changed files or features
- verification commands that passed
- warnings or checks not run
- unrelated existing dirty files left untouched

Do not say work is complete based only on confidence, visual inspection, or a previous run.
