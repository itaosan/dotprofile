#!/bin/bash

set -euo pipefail

this_dir="$(cd "$(dirname "$0")" && pwd)"

# グローバル設定 (~/.npmrc) のシンボリックリンクを作成/更新
ln -snf "$this_dir/.npmrc" "$HOME/.npmrc"
echo "Symlink created: $HOME/.npmrc -> npm/.npmrc"
