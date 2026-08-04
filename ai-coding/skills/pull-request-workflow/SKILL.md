---
name: pull-request-workflow
description: Use when drafting, creating, updating, or preparing a GitHub pull request, PR body, PR title, draft PR, push-before-PR flow, or Japanese pull request description from git diff, commits, or a repository PR template.
---

# Pull Request Workflow

Prepare pull requests from verified git changes, and run GitHub actions only when the user explicitly asks for them.

## Workflow

1. Inspect branch and dirty state with `git status --short --branch`.
2. Identify the base branch from the tracking branch, target branch, or user request. Stop and ask if the base is unclear.
3. Inspect scope with `git diff --stat <base>...HEAD`, targeted diffs as needed, and `git log --oneline <base>..HEAD`.
4. If uncommitted changes should be included, use `commit-changes` before creating or updating a PR.
5. Use `completion-check` before push, create, or update actions.
<!-- codex-security は CLI の Windows cp932 バグにより一時無効化中（2026-08-04）。復活時はコメントを外し番号を振り直す。
6. Before push or PR creation, run the `codex-security` skill against the outgoing diff (`--diff` or `--working-tree` scope). Skip only when the user explicitly waives the scan or the diff contains no code changes; note the scan result or the skip reason in the PR body.
-->
6. Read `.github/pull_request_template.md` when present and follow its structure.
7. If the work exposed blockers, errors, confusing setup, or recovery steps that future sessions should know, update the existing project handoff notes such as `CLAUDE.md` or `AGENTS.md`; skip this when there is nothing useful to preserve.
8. Draft the title and body in Japanese. Include summary, implementation details, tests or verification, and risk or follow-up notes when relevant.
9. Add a Mermaid diagram when architecture, data flow, component relationships, or process flow changed enough that a diagram clarifies the PR.
10. Execute GitHub actions only when explicitly requested:
   - Push branch: `git push -u origin <branch>`
   - Create draft PR: `gh pr create --draft`
   - Update existing PR body: `gh pr edit --body ...`

## Modes

- Default: draft the PR title/body and create a draft PR when requested.
- Push before PR: push the current branch, then create a draft PR when requested.
- Update PR: replace the existing PR body when requested.

## Guardrails

- Do not push, create, or update a PR when verification failed or is unknown.
- Do not push or create a PR while the security scan reports unresolved high-severity findings, unless the user explicitly accepts the risk.
- Do not include unrelated dirty changes in the PR summary.
- Do not assume `origin/HEAD...HEAD` is the correct comparison range when branch tracking is unclear.
- Do not create or inflate project memory files for routine work with no reusable lesson.
- Prefer draft PRs unless the user explicitly asks for ready-for-review.
