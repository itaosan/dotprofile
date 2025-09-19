#!/bin/bash

# 事前にやって置く
# BurntToastモジュールをインストール
#Install-Module -Name BurntToast -Force
# 実行ポリシーの設定（必要な場合）
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# デフォルト値
TITLE="通知"
MESSAGE=""

# オプション解析
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--title)
            TITLE="$2"
            shift 2
            ;;
        -m|--message)
            MESSAGE="$2"
            shift 2
            ;;
        *)
            if [ -z "$MESSAGE" ]; then
                MESSAGE="$1"
            fi
            shift
            ;;
    esac
done

# PowerShellで通知を表示
/mnt/c/Program\ Files/PowerShell/7/pwsh.exe -NoLogo -NoProfile -Command \
    "New-BurntToastNotification -Text \"$TITLE\", \"$MESSAGE\" -Sound Default"