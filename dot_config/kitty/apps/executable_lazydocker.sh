#!/bin/bash

# Needs colima or docker desktop
source "$(dirname "$0")/_launch.sh"
launch_tui_app LAZYDOCKER_TUI_APP -e /bin/zsh -c 'exec lazydocker'
