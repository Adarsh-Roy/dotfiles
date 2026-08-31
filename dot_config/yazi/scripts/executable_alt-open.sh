#!/usr/bin/env bash
# Alternate opener for Yazi, bound to <C-o> in keymap.toml.
#
# `o` keeps Yazi's normal behaviour (nvim for text, Preview for images).
# This script is the second way to open a file: one keypress, and which app
# it picks is decided per extension by the case block below.
#
# To teach it a new type, add one line to the case. The `*)` fallback hands
# the file to whatever app macOS has registered, which is the right answer
# often enough that most types never need an entry.

set -eu
[ $# -eq 0 ] && exit 0

BROWSER="Arc"

for f in "$@"; do
  # Lowercase the extension so .HTML and .html take the same branch.
  ext="${f##*.}"
  ext="$(printf '%s' "$ext" | tr '[:upper:]' '[:lower:]')"

  # A file with no dot in its name leaves $ext equal to the whole filename,
  # which would match nothing and fall through to the default — fine, but
  # blank it out so the case reads honestly.
  case "$f" in
    *.*) ;;
    *) ext="" ;;
  esac

  case "$ext" in
    html|htm|xhtml) open -a "$BROWSER" "$f" ;;
    svg)            open -a "$BROWSER" "$f" ;;
    # csv|tsv)      open -a "Numbers" "$f" ;;
    # md)           open -a "Obsidian" "$f" ;;
    *)              open "$f" ;;
  esac
done
