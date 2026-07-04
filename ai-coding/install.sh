#!/bin/bash

# 共通インストーラ: Claude Code と Codex を一括セットアップ
# Supports: macOS / Linux / WSL / Windows (Git Bash / MSYS2)

set -euo pipefail

: ${CLAUDE_HOME:="$HOME/.claude"}
: ${CODEX_HOME:="$HOME/.codex"}
: ${AGENTS_HOME:="$HOME/.agents"}

repo_root_dir="$(cd "$(dirname "$0")/.." && pwd)"
this_dir="$(cd "$(dirname "$0")" && pwd)"

# --- Windows (Git Bash / MSYS2): ネイティブシンボリックリンクを有効化 ---
case "$(uname -s)" in
  MINGW*|MSYS*)
    export MSYS=winsymlinks:nativestrict
    ;;
esac

mkdir -p "$CLAUDE_HOME" "$CODEX_HOME" "$AGENTS_HOME"

# 共通ドキュメントをリンク
rm -rf "$CLAUDE_HOME/CLAUDE.md"
ln -s "$this_dir/AGENTS.md" "$CLAUDE_HOME/CLAUDE.md"

rm -rf "$CODEX_HOME/AGENTS.md"
ln -s "$this_dir/AGENTS.md" "$CODEX_HOME/AGENTS.md"

# 参照元（ai-coding配下に統一）
agents_src="$this_dir/agents"
skills_src="$this_dir/skills"
pets_src="$this_dir/pets"
codex_config_src="$this_dir/codex/config.toml"
settings_src="$this_dir/claude/settings.json"
statusline_src="$this_dir/claude/statusline.py"
hooks_src="$this_dir/claude/hooks"
rules_src="$this_dir/claude/rules"

install_codex_config() {
  local target="$CODEX_HOME/config.toml"

  if [ -L "$target" ]; then
    rm "$target"
    cp "$codex_config_src" "$target"
    echo "Converted Codex config symlink to local file: $target"
  elif [ -e "$target" ]; then
    echo "Codex config exists; leaving local file untouched: $target"
    echo "Portable Codex config template: $codex_config_src"
  else
    cp "$codex_config_src" "$target"
    echo "Codex config created from portable template: $target"
  fi
}

install_codex_config

# 旧slash commandリンクを削除（ワークフローはSkillsへ集約）
rm -rf "$CLAUDE_HOME/commands"
rm -rf "$CODEX_HOME/prompts"

# Claude Code 専用リンク類
rm -rf "$CLAUDE_HOME/agents"
ln -s "$agents_src" "$CLAUDE_HOME/agents"

rm -rf "$CLAUDE_HOME/skills"
ln -s "$skills_src" "$CLAUDE_HOME/skills"

rm -rf "$CLAUDE_HOME/settings.json"
ln -s "$settings_src" "$CLAUDE_HOME/settings.json"

rm -rf "$CLAUDE_HOME/statusline.py"
ln -s "$statusline_src" "$CLAUDE_HOME/statusline.py"

rm -rf "$CLAUDE_HOME/hooks"
ln -s "$hooks_src" "$CLAUDE_HOME/hooks"

rm -rf "$CLAUDE_HOME/rules"
ln -s "$rules_src" "$CLAUDE_HOME/rules"

# Codex 用リンク類
rm -rf "$CODEX_HOME/agents"
ln -s "$agents_src" "$CODEX_HOME/agents"

# Codex Skills（公式の user scope）
if [ -L "$AGENTS_HOME/skills" ]; then
  rm "$AGENTS_HOME/skills"
fi
mkdir -p "$AGENTS_HOME/skills"
if [ -d "$skills_src" ]; then
  for skill_dir in "$skills_src"/*; do
    [ -d "$skill_dir" ] || continue
    skill_name="$(basename "$skill_dir")"
    skill_link="$AGENTS_HOME/skills/$skill_name"

    if [ -L "$skill_link" ]; then
      rm "$skill_link"
    elif [ -e "$skill_link" ]; then
      echo "Refusing to replace existing Codex skill: $skill_link" >&2
      echo "Remove or rename it, then run install.sh again." >&2
      exit 1
    fi

    ln -s "$skill_dir" "$skill_link"
  done
fi

# Codex Desktop 用ペット
mkdir -p "$CODEX_HOME/pets"
if [ -d "$pets_src" ]; then
  for pet_dir in "$pets_src"/*; do
    [ -d "$pet_dir" ] || continue
    pet_name="$(basename "$pet_dir")"
    rm -rf "$CODEX_HOME/pets/$pet_name"
    mkdir -p "$CODEX_HOME/pets/$pet_name"
    cp -R "$pet_dir/." "$CODEX_HOME/pets/$pet_name/"
  done
fi

echo ""
echo "Setup completed:"
echo "- Claude Code: $CLAUDE_HOME"
echo "- Codex     : $CODEX_HOME"
echo "- Codex Skills: $AGENTS_HOME/skills"
