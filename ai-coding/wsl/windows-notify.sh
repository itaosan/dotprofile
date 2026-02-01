#!/bin/bash

# 事前にやって置く
# BurntToastモジュールをインストール
#Install-Module -Name BurntToast -Force
# 実行ポリシーの設定（必要な場合）
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser


TYPE="${1:-info}"
MESSAGE="${2:-Claude Code}"

case "$TYPE" in
    "permission") TITLE="Claude Code - 許可が必要です" ;;
    "idle")       TITLE="Claude Code - 入力待ち" ;;
    "complete")   TITLE="Claude Code - 完了" ;;
    *)            TITLE="Claude Code" ;;
esac

# PowerShell 7 + BurntToastでWindows Toast通知を送信
"/mnt/c/Program Files/PowerShell/7/pwsh.exe" -NoProfile -Command "New-BurntToastNotification -Text '$TITLE', '$MESSAGE' -Sound Default" 2>/dev/null &

exit 0