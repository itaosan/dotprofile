---
name: x-url-reader
description: Use when web research includes X or Twitter URLs, x.com links, twitter.com links, tweet/status URLs, X threads, X profiles, or social posts that should be read through Jina Reader before relying on their contents.
---

# X URL Reader

Read X/Twitter URLs through Jina Reader before using their contents in web research.

## Workflow

1. Detect URLs whose host is `x.com`, `www.x.com`, `twitter.com`, `www.twitter.com`, or `mobile.twitter.com`.
2. Preserve the original URL for citation and reporting.
3. Build the Reader URL by prefixing the full original URL with `https://r.jina.ai/`.
   - Example: `https://x.com/user/status/123` -> `https://r.jina.ai/https://x.com/user/status/123`
4. Open or fetch the Reader URL and use the returned Markdown/text as the source material.
5. Report that the X/Twitter content was read through Jina Reader when the result matters to the answer.
6. If Reader cannot fetch useful content, stop using that URL as evidence and report the fetch failure or login/private-content limitation.

## Guardrails

- Do not treat private, deleted, age-gated, suspended, or login-only content as verified.
- Do not summarize an X/Twitter URL from search snippets alone when Reader fetch failed.
- Do not use Jina Reader for unrelated websites unless the user asks for it or the normal web fetch is unusable.
- Keep source attribution tied to the original X/Twitter URL, not only the `r.jina.ai` wrapper URL.
