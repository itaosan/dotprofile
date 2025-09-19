## セットアップ（共通インストーラ）
参考: `https://zenn.dev/karaage0703/articles/aabaa01cb71647`

```
chmod +x ai-coding/install.sh
./ai-coding/install.sh
```

### 共有リソース
- 共通エージェント定義: `ai-coding/AGENTS.md`（Claudeは `~/.claude/CLAUDE.md`、Codexは `~/.codex/AGENTS.md`）
- スラッシュコマンド: `ai-coding/commands`（無ければ旧`claude/commands`） → Claude: `~/.claude/commands`、Codex: `~/.codex/prompts`
- エージェント群: `ai-coding/agents`（無ければ旧`claude/agents`）