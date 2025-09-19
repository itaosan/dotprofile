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
### mise セットアップ

#### 使い方
- mise のインストール: `curl https://mise.run | sh`
- シェルへの有効化:
  - zsh → `echo 'eval "$(mise activate zsh)"' >> ~/.zshrc`
  - bash → `echo 'eval "$(mise activate bash)"' >> ~/.bashrc`

#### このリポジトリでの運用
- ルートにある `mise.toml` をバージョン管理
- `.env` は未コミット。サンプルは `.env.example`

#### よく使うタスク
- `mise run` : 対話的にタスク選択
- `mise run setup` : ツール一括インストール
- `mise run list-tools` : 管理ツール一覧
- `mise run update-tools` : ツール更新
- `mise run example` : 雛形タスク実行

#### 参考
- 記事: https://zenn.dev/dress_code/articles/a99ff13634bbe6
- GitHub: https://github.com/jdx/mise
- Docs: https://mise.jdx.dev/

> 注: 設定ファイルは `mise/mise.toml` に配置。互換のためルートにシンボリックリンク `mise.toml` を配置しています。
