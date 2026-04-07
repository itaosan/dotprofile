# dotprofile

AIコーディングエージェント（Claude Code / Codex CLI）の設定を一元管理するdotfilesリポジトリ。

## プロジェクト構造

```
dotprofile/
├── ai-coding/          # Claude Code・Codex CLI共通設定
│   ├── install.sh      # メインインストーラ（シンボリックリンク一括作成）
│   ├── AGENTS.md       # 共通エージェント定義（CLAUDE.md / AGENTS.mdにリンク）
│   ├── claude/         # Claude Code専用設定
│   │   ├── settings.json
│   │   ├── statusline.py
│   │   └── hooks/
│   ├── codex/          # Codex CLI専用設定
│   │   └── config.toml
│   ├── commands/       # スラッシュコマンド定義
│   ├── agents/         # エージェント定義
│   ├── skills/         # スキル定義
│   └── wsl/            # WSL固有スクリプト
├── mise/               # mise（ランタイムバージョン管理）
│   ├── config.toml     # グローバルツール定義
│   └── install.sh      # ~/.config/mise/config.toml へのシンボリックリンク作成
└── npm/                # npm設定
    ├── .npmrc          # グローバルnpmセキュリティ設定
    └── install.sh      # ~/.npmrc へのシンボリックリンク作成
```

## セットアップ

```bash
# Claude Code + Codex CLI
chmod +x ai-coding/install.sh && ./ai-coding/install.sh

# mise
chmod +x mise/install.sh && ./mise/install.sh

# npm
chmod +x npm/install.sh && ./npm/install.sh
```

## 設定追加のパターン（規約）

新しいツールの設定を追加する場合は以下の規約に従う。

1. `<tool>/` ディレクトリを作成
2. `<tool>/<config-file>` に設定ファイルを配置
3. `<tool>/install.sh` でホームディレクトリへのシンボリックリンクを作成
4. README.md にセットアップ手順を追記

### install.sh テンプレート

```bash
#!/bin/bash
set -euo pipefail

this_dir="$(cd "$(dirname "$0")" && pwd)"
ln -snf "$this_dir/<config-file>" "$HOME/.<config-file>"
echo "Symlink created: $HOME/.<config-file> -> <tool>/<config-file>"
```

## シンボリックリンク展開先一覧

| リポジトリ内パス | リンク先 |
|---|---|
| `ai-coding/AGENTS.md` | `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md` |
| `ai-coding/claude/settings.json` | `~/.claude/settings.json` |
| `ai-coding/claude/hooks/` | `~/.claude/hooks` |
| `ai-coding/commands/` | `~/.claude/commands`, `~/.codex/prompts` |
| `ai-coding/agents/` | `~/.claude/agents`, `~/.codex/agents` |
| `ai-coding/skills/` | `~/.claude/skills` |
| `ai-coding/codex/config.toml` | `~/.codex/config.toml` |
| `mise/config.toml` | `~/.config/mise/config.toml` |
| `npm/.npmrc` | `~/.npmrc` |

## 注意事項

- `ai-coding/install.sh` はシンボリックリンクを `ln -snf` で強制更新する（既存リンクを上書き）
- WSL2環境では `windows-notify.sh` を `~/bin/` にコピーする処理が含まれる
- Python パッケージ管理は `uv` を使用（`pip` 禁止）
