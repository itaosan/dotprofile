#!/bin/bash

#: ${XDG_CONFIG_HOME:="$HOME/.config"}
: ${XDG_CONFIG_HOME:="$HOME/.claude"}

# if [ ! -e "$XDG_CONFIG_HOME/claude" ]; then
#   mkdir -p "$XDG_CONFIG_HOME/claude"
# fi

# 既存ファイルがあっても強制的に置き換える
rm -rf "$XDG_CONFIG_HOME/CLAUDE.md"
ln -s "$PWD/CLAUDE.md" "$XDG_CONFIG_HOME/CLAUDE.md"

rm -rf "$XDG_CONFIG_HOME/commands"
ln -s "$PWD/commands" "$XDG_CONFIG_HOME/commands"

rm -rf "$XDG_CONFIG_HOME/settings.json"
ln -s "$PWD/settings.json" "$XDG_CONFIG_HOME/settings.json"

