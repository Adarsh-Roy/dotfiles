#!/bin/bash

CFG="$HOME/.config/aerospace/aerospace.toml"

if grep -q 'outer.bottom=80' "$CFG"; then
  # Turn recording gap OFF
  sed -i '' 's/outer.bottom=80/outer.bottom=4/' "$CFG"
else
  # Turn recording gap ON
  sed -i '' 's/outer.bottom=4/outer.bottom=80/' "$CFG"
fi

# Reload Aerospace config without popping the GUI
aerospace reload-config --no-gui
