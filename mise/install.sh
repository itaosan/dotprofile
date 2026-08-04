#!/bin/bash

# mise 設定インストーラ
# Supports: macOS / Linux / WSL / Windows (Git Bash / MSYS2)

set -euo pipefail

this_dir="$(cd "$(dirname "$0")" && pwd)"

# --- Windows (Git Bash / MSYS2): ネイティブシンボリックリンクを有効化 ---
# これが無いと ln -s が無言でコピーに劣化し、リポジトリ側の編集が伝播しない。
case "$(uname -s)" in
  MINGW*|MSYS*)
    export MSYS=winsymlinks:nativestrict
    ;;
esac

# グローバル設定 (~/.config/mise/config.toml) のシンボリックリンクを作成/更新
global_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/mise"
global_config="$global_config_dir/config.toml"
mkdir -p "$global_config_dir"

# 既存がリンクでない実ファイルの場合はバックアップしてから置き換える
if [ -f "$global_config" ] && [ ! -L "$global_config" ]; then
  backup="$global_config.bak-$(date +%Y%m%d-%H%M%S)"
  cp "$global_config" "$backup"
  echo "Existing config backed up: $backup"
fi

rm -f "$global_config"
ln -s "$this_dir/config.toml" "$global_config"

# リンク生成の検証（Windows でコピーに劣化していないか確認）
if [ -L "$global_config" ]; then
  echo "Symlink created: $global_config -> mise/config.toml"
else
  echo "ERROR: $global_config is not a symlink (copy fallback detected)." >&2
  echo "       Windows では開発者モードを有効にするか、管理者権限で再実行してください。" >&2
  exit 1
fi
