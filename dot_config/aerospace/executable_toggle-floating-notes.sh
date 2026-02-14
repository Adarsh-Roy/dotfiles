#!/bin/bash

TITLE="FLOATING_NOTES"
HIDDEN_WS="N0TES"

# Find the floating notes window by title (use tab separator to avoid awk issues)
WINDOW_ID=$(aerospace list-windows --all --format '%{window-id}%{tab}%{window-title}' \
    | grep "	${TITLE}$" \
    | cut -f1 \
    | head -1)

if [ -z "$WINDOW_ID" ]; then
    open -n /Applications/WezTerm.app --args --config-file "$HOME/.config/wezterm/floating_notes.lua"
    exit 0
fi

# Get workspace for this window
CURRENT_WS=$(aerospace list-windows --all --format '%{window-id}%{tab}%{workspace}' \
    | grep "^${WINDOW_ID}	" \
    | cut -f2)

FOCUSED_WS=$(aerospace list-workspaces --focused)

if [ "$CURRENT_WS" = "$HIDDEN_WS" ]; then
    aerospace move-node-to-workspace --window-id "$WINDOW_ID" "$FOCUSED_WS"
    aerospace focus --window-id "$WINDOW_ID"
elif [ "$CURRENT_WS" = "$FOCUSED_WS" ]; then
    aerospace move-node-to-workspace --window-id "$WINDOW_ID" "$HIDDEN_WS"
else
    aerospace move-node-to-workspace --window-id "$WINDOW_ID" "$FOCUSED_WS"
    aerospace focus --window-id "$WINDOW_ID"
fi
