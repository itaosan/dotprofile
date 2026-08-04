# dotprofile Repository Guidance

- このリポジトリは、AIコーディングエージェント向けの個人設定を一元管理する。
- `ai-coding/` 配下は Claude Code / Codex / Codex CLI に配布する設定本体。
- ルートの `AGENTS.md` / `CLAUDE.md` は、このリポジトリ自体を編集するエージェント向けの案内。

## 方針

- 共通化できる作業手順は `ai-coding/skills/<skill-name>/SKILL.md` に寄せる。
- Slash command は廃止方針。新規 command は追加しない。
- 環境依存のMCP runtime pathやローカル生成設定はこのリポジトリでは管理しない。
- 通知は Codex App / Claude Desktop / Claude Code の標準機能を優先し、独自通知スクリプトを増やさない。
- `ai-coding/AGENTS.md` は常時ロードされる短い索引と基本方針に留める。
- 長い手順、調査手順、コミット/PR規律、Python運用は Skill に置く。

## 主要パス

| パス | 役割 |
|---|---|
| `ai-coding/AGENTS.md` | 配布先の `CLAUDE.md` / `AGENTS.md` になる共通エージェント定義 |
| `ai-coding/skills/` | Claude Code と Codex で共有する Skill |
| `ai-coding/claude/` | Claude Code 専用の settings / hooks / rules / statusline |
| `ai-coding/codex/config.toml` | Codex 用のポータブルな初期設定テンプレート |
| `ai-coding/install.sh` | 各ホームディレクトリへのリンク・初期設定展開 |
| `README.md` | ユーザー向けの構成とセットアップ説明 |

## 編集ルール

- 既存の未コミット変更はユーザー作業として扱い、勝手に戻さない。
- `ai-coding/install.sh` の展開先を変えたら `README.md` も更新する。
- Skill を追加・移動・削除したら、公式構成に合うか確認する。
- Codex の `config.toml` には、ランタイムパス、trusted project、marketplace、通知コマンドなど環境依存値を入れない。

## 検証

検証コマンドは `agent-config-maintenance` Skill の「Validation Commands」に従う。
