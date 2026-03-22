#!/bin/bash

# Cross-platform notification script for Claude Code hooks
# Supports: macOS (osascript) / WSL (PowerShell + BurntToast)

TITLE="Claude Code"
MESSAGE="通知"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t) TITLE="$2"; shift 2 ;;
    -m) MESSAGE="$2"; shift 2 ;;
    *)  shift ;;
  esac
done

case "$(uname -s)" in
  Darwin)
    osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\"" 2>/dev/null &
    ;;
  Linux)
    if grep -qi microsoft /proc/version 2>/dev/null; then
      # WSL: PowerShell 7 + BurntToast
      "/mnt/c/Program Files/PowerShell/7/pwsh.exe" -NoProfile -Command \
        "New-BurntToastNotification -Text '$TITLE', '$MESSAGE' -Sound Default" 2>/dev/null &
    fi
    ;;
esac

exit 0
