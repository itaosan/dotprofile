---
name: bug-fix-workflow
description: Use when investigating, reproducing, fixing, or verifying a bug from a user report, failing test, runtime error, regression, stack trace, or unexpected behavior.
---

# Bug Fix Workflow

Fix bugs by proving the failure, changing the smallest necessary behavior, and verifying the original symptom.

## Workflow

1. Restate the observed bug and expected behavior.
2. Inspect the relevant code, tests, logs, and recent changes.
3. Reproduce the issue with the smallest reliable case.
4. Add or identify a failing test when the codebase supports tests.
5. If the bug depends on a library, framework, SDK, CLI, or cloud service, use `find-docs` to verify current behavior from primary sources.
6. Fix the root cause with the smallest scoped change.
7. Run the failing test or reproduction again and confirm it passes.
8. Run related regression checks.
9. If a new error appears, repeat the workflow from reproduction instead of stacking guesses.

## Guardrails

- Do not relax tests, types, validation, or assertions just to make the failure disappear.
- Do not hide or ignore error output.
- Do not add a fallback path unless the user explicitly wants one.
- If the issue cannot be reproduced, report what was checked and ask for the missing signal.

## Report

Keep the final report brief:

- root cause
- changed behavior
- tests or reproduction used
- remaining risk or missing coverage
