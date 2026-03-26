#!/bin/bash
# Module: Homebrew GUI Applications (macOS only)

[[ "$OSTYPE" != "darwin"* ]] && echo -e "${YELLOW}[brew-gui] skipping (not macOS)${NC}" && return 0

# ── Core GUI apps (required by dotfiles configs) ──
echo -e "${BLUE}[brew-gui]${NC} Installing core GUI applications..."
echo -e "${BLUE}[brew-gui]${NC} Core: wezterm, aerospace, karabiner, raycast, leader-key, mouseless, font-maple-mono-nf"

brew bundle --no-lock --verbose --file=/dev/stdin <<EOF
tap "nikitabobko/tap"
cask "wezterm"
cask "nikitabobko/tap/aerospace"
cask "karabiner-elements"
cask "raycast"
cask "leader-key"
cask "mouseless"
cask "font-maple-mono-nf"
EOF

echo -e "${GREEN}[brew-gui]${NC} Core GUI applications installed"

# ── Optional GUI apps ──
echo ""
echo -e "${YELLOW}[brew-gui]${NC} The following optional apps can also be installed:"
echo "  Communication : slack, discord, whatsapp, zoom"
echo "  Browser       : google-chrome"
echo "  Development   : postman"
echo "  Media         : spotify, obs"
echo "  Typing        : thock"
echo ""
read -r -p "Install optional GUI apps? [y/N] " opt_response </dev/tty
if [[ "$opt_response" =~ ^[Yy]$ ]]; then
  echo -e "${BLUE}[brew-gui]${NC} Installing optional GUI applications..."
  brew bundle --no-lock --verbose --file=/dev/stdin <<EOF
cask "slack"
cask "discord"
cask "whatsapp"
cask "zoom"
cask "google-chrome"
cask "postman"
cask "spotify"
cask "obs"
cask "thock"
EOF
  echo -e "${GREEN}[brew-gui]${NC} Optional GUI applications installed"
else
  echo -e "${YELLOW}[brew-gui]${NC} Skipped optional GUI apps"
fi
