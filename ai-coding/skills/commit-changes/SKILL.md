---
name: commit-changes
description: Use when preparing, staging, splitting, committing, or optionally pushing git changes, especially when the user asks to commit, asks to push after committing, or asks for an atomic Japanese conventional commit message.
---

# Commit Changes

Create small, verified commits whose message matches the actual diff.

## Workflow

1. Inspect the working tree with `git status --short --branch`.
2. Inspect staged and unstaged diffs with `git diff --stat`, `git diff`, and `git diff --cached` as needed.
3. Separate unrelated or pre-existing user changes from the intended commit.
4. Run verification that fits the changed surface:
   - project tests, build, lint, typecheck, or the closest available checks
   - `completion-check` for agent configuration, docs, hooks, installers, and skills
5. Do not commit if applicable tests, build, typecheck, lint, or compiler checks fail or produce unresolved warnings.
6. Split multiple logical changes into separate commits when the diff crosses concerns.
7. Stage only the files for the current logical commit.
8. Re-check `git diff --cached` before committing.
9. Commit with an emoji conventional message in Japanese.
10. Push only when the user explicitly requested it.

## Commit Message

Use this format:

```text
<emoji> <type>: <Japanese summary>
```

Common types:

| Type | Emoji | Use |
|---|---|---|
| `feat` | `✨` | user-visible feature or capability |
| `fix` | `🐛` | bug fix |
| `docs` | `📝` | documentation |
| `refactor` | `♻️` | structure change without behavior change |
| `test` | `✅` | tests |
| `chore` | `🔧` | tooling, config, maintenance |
| `ci` | `🚀` | CI/CD |
| `revert` | `⏪️` | revert |

Keep the first line concise. State whether the commit is primarily structural, behavioral, documentation, test, or tooling work.

## Safety

- Never use `git reset --hard` or `git checkout --` to prepare a commit unless the user explicitly asked for that destructive operation.
- Do not stage unrelated dirty files just because they exist.
- If files are already staged, assume the user staged them intentionally and verify before changing the staging area.
- `--no-verify` may skip git hooks only when explicitly requested; it does not remove the requirement to inspect the diff and report verification status.
