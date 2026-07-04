---
name: find-docs
description: Use when current official documentation, API references, release notes, or code examples are needed for a library, framework, SDK, CLI tool, cloud service, or platform-specific behavior.
---

# Find Docs

## Workflow

1. Identify the exact technology, package, SDK, CLI, cloud service, and version if known.
2. Prefer primary sources: official documentation, official API references, release notes, changelogs, RFCs, standards, and source repositories.
3. Use the documentation or browsing tools available in the current agent environment.
4. For OpenAI products, use official OpenAI documentation sources.
5. Compare publication date, version, and deprecation notices before relying on a result.
6. If sources disagree, prefer the newest official source and name the conflict.
7. If no current source can be reached, stop and report that the information could not be verified.

## Query Rules

- Use the user's full question as the search/query text when possible.
- Include version numbers, runtime names, error messages, and framework mode names.
- Do not include API keys, tokens, secrets, private code, or personal data in external queries.
- Avoid relying on training data for API signatures, configuration keys, or migration steps.

## Report Shape

Keep the answer concise:

- source and date/version checked
- answer or implementation guidance
- caveats, deprecated APIs, or uncertainty
- links when the environment supports them
