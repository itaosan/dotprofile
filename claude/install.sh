#!/bin/bash

#: ${XDG_CONFIG_HOME:="$HOME/.config"}
: ${XDG_CONFIG_HOME:="$HOME/.claude"}

# if [ ! -e "$XDG_CONFIG_HOME/claude" ]; then
#   mkdir -p "$XDG_CONFIG_HOME/claude"
# fi

# 既存ファイルがあっても強制的に置き換える
ln -sf "$PWD/CLAUDE.md" "$XDG_CONFIG_HOME/CLAUDE.md"

ln -sf "$PWD/commands" "$XDG_CONFIG_HOME/commands"

ln -sf "$PWD/settings.json" "$XDG_CONFIG_HOME/settings.json"

