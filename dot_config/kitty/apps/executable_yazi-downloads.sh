#!/bin/bash
source "$(dirname "$0")/_launch.sh"
launch_tui_app YAZI_DOWNLOADS_TUI_APP -e /bin/zsh -c 'exec yazi "$HOME/Downloads"'
