#!/usr/bin/env bash
# Put one or more files on the macOS pasteboard as file references,
# so they can be pasted into Finder, WhatsApp, Mail, Slack, Raycast,
# etc. Uses the legacy NSFilenamesPboardType (setPropertyList) — the
# modern writeObjects:[NSPasteboardItem] path intermittently drops
# items, which was producing only the first/second file on paste.

set -eu
[ $# -eq 0 ] && exit 0

osascript - "$@" <<'APPLESCRIPT' >/dev/null
use framework "AppKit"
use framework "Foundation"
use scripting additions

on run argv
    set pb to current application's NSPasteboard's generalPasteboard()
    pb's clearContents()
    set paths to current application's NSMutableArray's array()
    repeat with p in argv
        (paths's addObject:(p as text))
    end repeat
    pb's declareTypes:{"NSFilenamesPboardType"} owner:(missing value)
    pb's setPropertyList:paths forType:"NSFilenamesPboardType"
end run
APPLESCRIPT
