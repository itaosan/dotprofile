#!/bin/bash

# 共通インストーラ: Claude Code と Codex CLI を一括セットアップ

set -euo pipefail

: ${CLAUDE_HOME:="$HOME/.claude"}
: ${CODEX_HOME:="$HOME/.codex"}

repo_root_dir="$(cd "$(dirname "$0")/.." && pwd)"
this_dir="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$CLAUDE_HOME" "$CODEX_HOME"

# 共通ドキュメントをリンク
rm -rf "$CLAUDE_HOME/CLAUDE.md"
ln -s "$this_dir/AGENTS.md" "$CLAUDE_HOME/CLAUDE.md"

rm -rf "$CODEX_HOME/AGENTS.md"
ln -s "$this_dir/AGENTS.md" "$CODEX_HOME/AGENTS.md"
rm -rf "$CODEX_HOME/config.toml"
ln -s "$this_dir/codex/config.toml" "$CODEX_HOME/config.toml"

# 参照元（ai-coding配下に統一）
commands_src="$this_dir/commands"
agents_src="$this_dir/agents"
settings_src="$this_dir/claude/settings.json"
statusline_src="$this_dir/claude/statusline-detailed.sh"
wsl_notify_src="$this_dir/wsl/windows-notify.sh"

# Claude Code 専用リンク類
rm -rf "$CLAUDE_HOME/commands"
ln -s "$commands_src" "$CLAUDE_HOME/commands"

rm -rf "$CLAUDE_HOME/agents"
ln -s "$agents_src" "$CLAUDE_HOME/agents"

rm -rf "$CLAUDE_HOME/settings.json"
ln -s "$settings_src" "$CLAUDE_HOME/settings.json"

rm -rf "$CLAUDE_HOME/statusline-detailed.sh"
ln -s "$statusline_src" "$CLAUDE_HOME/statusline-detailed.sh"

# Codex CLI 用リンク類
rm -rf "$CODEX_HOME/prompts"
ln -s "$commands_src" "$CODEX_HOME/prompts"

rm -rf "$CODEX_HOME/agents"
ln -s "$agents_src" "$CODEX_HOME/agents"

# WSL 環境向けの通知スクリプト（共通）
if [ -e "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe" ]; then
  mkdir -p ~/bin
  cp "$wsl_notify_src" ~/bin/windows-notify.sh
  chmod +x ~/bin/windows-notify.sh
fi

echo "Setup completed:"
echo "- Claude Code: $CLAUDE_HOME"
echo "- Codex CLI : $CODEX_HOME"


