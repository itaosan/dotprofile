---
paths:
  - "ai-coding/**"
  - ".claude/**"
  - ".codex/**"
  - "CLAUDE.md"
  - "AGENTS.md"
---

エージェント設定を更新するときは、常時ロードされる `CLAUDE.md` / `AGENTS.md` を索引として扱う。

- 常時必要な概要、構成、共通規約だけを `CLAUDE.md` / `AGENTS.md` に置く。
- 長い手順は `skills/` に置く。
- パス限定の短い制約は `rules/` に置く。
- 決定的に強制したい制約は `settings.json` の permissions / hooks に置く。
- subagentに任せるべき調査やログ解析は `agents/` に置く。
- 設定ファイルや配置先を増やしたら、`install.sh` と `README.md` も更新する。
