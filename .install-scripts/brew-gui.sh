#!/bin/bash
# Module: Homebrew GUI Applications (macOS only)

[[ "$OSTYPE" != "darwin"* ]] && echo "brew-gui.sh: skipping (not macOS)" && return 0

echo -e "${GREEN}Installing Homebrew GUI applications...${NC}"

brew bundle --no-lock --file=/dev/stdin <<EOF
# Taps
tap "nikitabobko/tap"

# Terminal
cask "wezterm"

# Window Management
cask "nikitabobko/tap/aerospace"
cask "karabiner-elements"

# Productivity
cask "raycast"
cask "leader-key"
cask "thock"
cask "mouseless"

# Communication
cask "slack"
cask "discord"
cask "whatsapp"
cask "zoom"

# Browsers
cask "google-chrome"

# Development
cask "postman"

# Media & Design
cask "spotify"
cask "obs"

# Fonts
cask "font-maple-mono-nf"
EOF

echo -e "${GREEN}Homebrew GUI applications installed${NC}\n"
