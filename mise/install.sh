#!/bin/bash

set -euo pipefail

# リポジトリ直下に `mise.toml` のシンボリックリンクを作成/更新
repo_root_dir="$(cd "$(dirname "$0")/.." && pwd)"
this_dir="$(cd "$(dirname "$0")" && pwd)"

ln -snf "$this_dir/mise.toml" "$repo_root_dir/mise.toml"

echo "Symlink created: $repo_root_dir/mise.toml -> mise/mise.toml"

# 任意: .env.example があり .env が無い場合に雛形をコピー（安全な初回支援）
if [ -f "$repo_root_dir/.env.example" ] && [ ! -f "$repo_root_dir/.env" ]; then
  cp "$repo_root_dir/.env.example" "$repo_root_dir/.env"
  echo ".env created from .env.example"
fi

# 参考: ルートで mise を使うとき
#   mise run                 # 対話的一覧
#   mise run setup           # 初回セットアップ
#   mise run update-tools    # ツール更新

