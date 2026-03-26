#!/bin/bash
# Module: Homebrew GUI Applications (macOS only)

[[ "$OSTYPE" != "darwin"* ]] && echo "brew-gui.sh: skipping (not macOS)" && return 0

# ── Core GUI apps (required by dotfiles configs) ──
echo -e "${GREEN}Installing core GUI applications...${NC}"

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
cask "mouseless"

# Fonts
cask "font-maple-mono-nf"
EOF

echo -e "${GREEN}Core GUI applications installed${NC}\n"

# ── Optional GUI apps ──
echo ""
echo -e "${YELLOW}The following optional apps can also be installed:${NC}"
echo "  Communication : slack, discord, whatsapp, zoom"
echo "  Browser       : google-chrome"
echo "  Development   : postman"
echo "  Media         : spotify, obs"
echo "  Typing        : thock"
echo ""
read -r -p "Install optional GUI apps? [y/N] " opt_response
if [[ "$opt_response" =~ ^[Yy]$ ]]; then
  echo -e "${GREEN}Installing optional GUI applications...${NC}"
  brew bundle --no-lock --file=/dev/stdin <<EOF
# Communication
cask "slack"
cask "discord"
cask "whatsapp"
cask "zoom"

# Browsers
cask "google-chrome"

# Development
cask "postman"

# Media
cask "spotify"
cask "obs"

# Typing
cask "thock"
EOF
  echo -e "${GREEN}Optional GUI applications installed${NC}\n"
else
  echo -e "${YELLOW}Skipped optional GUI apps${NC}\n"
fi
