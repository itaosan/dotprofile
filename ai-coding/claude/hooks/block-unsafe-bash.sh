#!/bin/bash
set -euo pipefail

input="$(cat)"

# Windows では python3/python が Microsoft Store のスタブ（存在するが実行不可）のことがある。
# command -v だけで選ぶとスタブを掴んで毎回失敗するため、jq を最優先し、
# インタプリタは実行 probe が通ったものだけを使う。
read_command() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$input" | jq -r '.tool_input.command // empty'
    return 0
  fi
  local py
  for py in python3 python; do
    if command -v "$py" >/dev/null 2>&1 && "$py" -c 'pass' >/dev/null 2>&1; then
      printf '%s' "$input" | "$py" -c 'import json, sys; data = json.load(sys.stdin); print(data.get("tool_input", {}).get("command", ""))'
      return 0
    fi
  done
  if command -v node >/dev/null 2>&1; then
    printf '%s' "$input" | node -e 'const fs = require("fs"); const data = JSON.parse(fs.readFileSync(0, "utf8")); console.log(data?.tool_input?.command || "");'
    return 0
  fi
  return 3
}

if ! command="$(read_command)"; then
  echo "Bash hook could not parse tool input: jq, python3, python, or node is required." >&2
  exit 2
fi

if [ -z "$command" ]; then
  exit 0
fi

block() {
  echo "$1" >&2
  exit 2
}

if printf '%s\n' "$command" | grep -Eq 'rm[[:space:]]+-[[:alnum:]]*r[[:alnum:]]*f[[:alnum:]]*[[:space:]]+(/|~|"$HOME"|\$HOME)'; then
  block "危険な再帰削除コマンドは実行できません。対象を限定した安全な方法を検討してください。"
fi

if printf '%s\n' "$command" | grep -Eq '(^|[;&|])[[:space:]]*sudo[[:space:]]+rm([[:space:]]|$)'; then
  block "sudo rm は実行できません。破壊範囲を確認できる別手順を提示してください。"
fi

if printf '%s\n' "$command" | grep -Eq '(^|[;&|])[[:space:]]*(pip|pip3)([[:space:]]|$)|(^|[;&|])[[:space:]]*python3?[[:space:]]+-m[[:space:]]+pip([[:space:]]|$)'; then
  block "Pythonパッケージ管理には uv を使用してください。pip / pip3 / python -m pip は禁止です。"
fi

if printf '%s\n' "$command" | grep -Eq 'git[[:space:]]+reset[[:space:]]+--hard|git[[:space:]]+checkout[[:space:]]+--'; then
  block "git reset --hard / git checkout -- はユーザーの明示確認なしに実行できません。"
fi

if printf '%s\n' "$command" | grep -Eq 'dd[[:space:]].*if=|format[[:space:]]|:\(\)[[:space:]]*\{[[:space:]]*:\|:'; then
  block "危険なシステム操作は実行できません。"
fi

exit 0
