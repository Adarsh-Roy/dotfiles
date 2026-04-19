#!/bin/bash
# Shared launcher helper for TUI-app scripts.
#
# Usage (source this from a per-TUI .sh launcher):
#
#   source "$(dirname "$0")/_launch.sh"
#   launch_tui_app <TITLE> <extra-kitty-args...> -e <cmd> [cmd-args...]
#
# Behavior (matches native app UX):
#   - If a Kitty window with matching title already exists, focus it in place.
#     Aerospace switches to whichever workspace it lives on. The window is
#     never moved, so existing layout on that workspace is preserved.
#   - If no such window exists, spawn a fresh Kitty instance floating on
#     the current workspace (via the catch-all _TUI_APP rule in aerospace.toml).
#
# The helper always prepends --title and --config _app.conf. Any extra args
# the caller passes (e.g., --directory, another --config for _tabs.conf,
# and the -e <cmd> tail) are appended verbatim.

launch_tui_app() {
  local title="$1"; shift

  local existing
  existing=$(aerospace list-windows --all \
    --format '%{window-id}%{tab}%{window-title}' 2>/dev/null \
    | grep "	${title}$" | cut -f1 | head -1)

  if [[ -n "$existing" ]]; then
    aerospace focus --window-id "$existing"
    return 0
  fi

  exec open -n /Applications/kitty.app --args \
    --title "$title" \
    --config "$HOME/.config/kitty/apps/_app.conf" \
    "$@"
}
