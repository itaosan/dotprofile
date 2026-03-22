#!/bin/bash

set -euo pipefail

this_dir="$(cd "$(dirname "$0")" && pwd)"

# グローバル設定 (~/.config/mise/config.toml) のシンボリックリンクを作成/更新
global_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/mise"
mkdir -p "$global_config_dir"
ln -snf "$this_dir/config.toml" "$global_config_dir/config.toml"
echo "Symlink created: $global_config_dir/config.toml -> mise/config.toml"
