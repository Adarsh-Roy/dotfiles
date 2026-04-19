#!/bin/bash
source "$(dirname "$0")/_launch.sh"
launch_tui_app YAZI_ROOT_TUI_APP -e /bin/zsh -c 'exec yazi "$HOME"'
