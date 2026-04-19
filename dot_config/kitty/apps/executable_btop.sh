#!/bin/bash
source "$(dirname "$0")/_launch.sh"
launch_tui_app BTOP_TUI_APP -e /bin/zsh -c 'exec btop'
