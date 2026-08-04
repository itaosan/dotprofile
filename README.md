# dotprofile

AIコーディングエージェント（Claude Code / Codex / Codex CLI）の設定を一元管理するdotfilesリポジトリ。

## セットアップ

```bash
chmod +x ai-coding/install.sh
./ai-coding/install.sh
```

## ai-coding の構成

| リポジトリ内パス | 展開先 | 役割 |
|---|---|---|
| `ai-coding/AGENTS.md` | `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md` | 常時ロードされる共通の索引・基本方針 |
| `ai-coding/claude/settings.json` | `~/.claude/settings.json` | Claude Code の permissions / hooks / plugins |
| `ai-coding/claude/hooks/` | `~/.claude/hooks` | Claude Code の決定的な自動化・ブロック処理 |
| `ai-coding/claude/rules/` | `~/.claude/rules` | Claude Code の短い制約・path-scoped rules |
| `ai-coding/claude/statusline.py` | `~/.claude/statusline.py` | Claude Code のステータスライン |
| `ai-coding/agents/` | `~/.claude/agents`, `~/.codex/agents` | subagent 定義 |
| `ai-coding/skills/<skill-name>` | `~/.claude/skills`, `~/.agents/skills/<skill-name>` | Claude Code / Codex 共通 skill 定義 |
| `ai-coding/codex/config.toml` | `~/.codex/config.toml` 初回コピー | Codex / Codex CLI のポータブル初期設定テンプレート |
| `ai-coding/pets/<pet-name>` | `~/.codex/pets/<pet-name>` | Codex Desktop 用ペット（実体コピー） |

`~/.codex/config.toml` は環境ごとの runtime path、trusted project、marketplace、通知コマンドを持つことがあるため、既存ファイルは上書きしない。

## 設定追加の方針

- `AGENTS.md` / `CLAUDE.md`: 常時必要な概要、構成、共通規約、索引だけを書く。
- `claude/rules/`: 特定ファイルや短い制約にだけ適用したい Claude Code ルールを置く。
- `skills/`: 調査、レビュー、リリースなどの長い手順を置く。Claude Code は `~/.claude/skills`、Codex は公式の user scope である `~/.agents/skills/<skill-name>` から同じ実体を読む。
- `agents/`: メイン文脈から隔離したい調査・ログ解析・監査を置く。
- `claude/hooks/` と `claude/settings.json`: 危険コマンド拒否、SessionStartの自動準備など決定的な処理を置く。
- `codex/config.toml`: 現在のローカル設定をベースに、通知コマンド、runtime path、trusted project、marketplace状態など環境依存部分だけを除いたポータブル設定を置く。
- Skill の `agents/openai.yaml`: Codex App 用の任意メタデータ。UI表示、明示プロンプト、依存ツール宣言が必要な場合だけ置く。

設定ファイルや展開先を追加した場合は、`ai-coding/install.sh` とこのREADMEを合わせて更新する。

## 共通Skill

| Skill | 役割 |
|---|---|
| `session-start` | 作業開始・再開時に `pwd`、Git状態、直近commit、未コミット差分を確認する |
| `task-planning` | 実装前に目標、制約、変更対象、検証方針を整理して承認を得る |
| `bug-fix-workflow` | バグを再現し、根本原因を修正して回帰確認する |
| `completion-check` | 完了報告・コミット・PR前に差分と環境に合う検証を確認する |
| `agent-config-maintenance` | `ai-coding/` 配下のClaude Code / Codex共通設定を保守する |
| `project-config-sync` | プロジェクト内の AGENTS.md / CLAUDE.md / Skills を単一ソースで両ツール対応にする |
| `python-package-management` | Python依存関係と実行方法を `uv` に統一する |
| `commit-changes` | 検証済みの小さなコミットを日本語メッセージで作成する |
| `pull-request-workflow` | Git差分から日本語PR本文を作成し、明示指示時にPRを作成・更新する |
| `github-repo-setup` | GitHubリポジトリの新規作成とセキュリティ初期設定6項目を適用する |
| `find-docs` | ライブラリ、SDK、CLI、クラウドサービスの公式情報を確認する |
| `x-url-reader` | Web調査でX/Twitter URLをJina Reader経由で読む |
| `dig` | 曖昧な仕様や計画を構造化質問で深掘りする |
| `grilling` | 計画・設計・意思決定を1問ずつ徹底インタビューして磨き上げる |
| `grill-me` | `/grill-me` の明示呼び出しで `grilling` セッションを開始する |
| `reviewing-skills` | Skill定義と構成をレビューする |
| `codex-security` | **一時無効化中**（CLI の Windows cp932 バグ。`SKILL.md.disabled` を戻せば復活）OpenAI Codex Security CLIで脆弱性スキャンと結果対応を行う |

## 検証

```bash
bash -n ai-coding/install.sh
tmp_claude="$(mktemp -d)"
tmp_codex="$(mktemp -d)"
tmp_agents="$(mktemp -d)"
CLAUDE_HOME="$tmp_claude" CODEX_HOME="$tmp_codex" AGENTS_HOME="$tmp_agents" ./ai-coding/install.sh
```
