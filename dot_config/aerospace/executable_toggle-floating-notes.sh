#!/bin/bash

TITLE="FLOATING_NOTES" # The window title we set in ../wezterm/floating_notes.lua
HIDDEN_WS="HIDDEN"

# Find the floating notes window by title
WINDOW_ID=$(aerospace list-windows --all --format '%{window-id}%{tab}%{window-title}' \
    | grep "	${TITLE}$" \
    | cut -f1 \
    | head -1)

# Check if the floating notes window is opened up, if not, open it and exit
if [ -z "$WINDOW_ID" ]; then
    open -n /Applications/WezTerm.app --args --config-file "$HOME/.config/wezterm/floating_notes.lua"
    exit 0
fi

# Get workspace for the floating notes window
CURRENT_WS=$(aerospace list-windows --all --format '%{window-id}%{tab}%{workspace}' \
    | grep "^${WINDOW_ID}	" \
    | cut -f2)

FOCUSED_WS=$(aerospace list-workspaces --focused)

if [ "$CURRENT_WS" = "$FOCUSED_WS" ]; then
    # It is currently here -> Hide it
    aerospace move-node-to-workspace --window-id "$WINDOW_ID" "$HIDDEN_WS"
else
    # It is NOT here (either hidden or on another screen) -> Summon it
    aerospace move-node-to-workspace --window-id "$WINDOW_ID" "$FOCUSED_WS"
    aerospace focus --window-id "$WINDOW_ID"

    # Auto-fix if window stuck at bottom-right (AeroSpace parking bug)
    sleep 0.05
    POS=$(osascript -e '
        tell application "System Events"
            repeat with p in (every process whose name is "wezterm-gui")
                repeat with w in (every window of p)
                    if name of w contains "FLOATING_NOTES" then
                        return position of w
                    end if
                end repeat
            end repeat
        end tell' 2>/dev/null)
    Y=$(echo "$POS" | cut -d',' -f2 | tr -d ' ')
    if [ -n "$Y" ] && [ "$Y" -gt 500 ]; then
        aerospace layout floating tiling --window-id "$WINDOW_ID"
        sleep 0.05
        aerospace layout floating tiling --window-id "$WINDOW_ID"
    fi
fi
