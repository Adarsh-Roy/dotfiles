#!/bin/bash
source "$(dirname "$0")/_launch.sh"
mkdir -p "$HOME/claude-default"
launch_tui_app CLAUDE_TUI_APP \
  --directory "$HOME/claude-default" \
  -e /bin/zsh -c 'exec "$HOME/.local/bin/claude" --model opus --effort medium --permission-mode default'
