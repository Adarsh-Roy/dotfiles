#!/bin/bash
set -euo pipefail

REPO="Adarsh-Roy/dotfiles"
BRANCH="install-script"

export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export NC='\033[0m'

echo -e "${BLUE}macOS Bootstrap — $REPO${NC}"
echo "=========================="

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "ERROR: This script is for macOS only"
  exit 1
fi

# ── 1. Homebrew ──
if ! command -v brew &> /dev/null; then
  echo -e "${GREEN}Installing Homebrew...${NC}"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ $(uname -m) == "arm64" ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
else
  echo -e "${GREEN}Homebrew already installed${NC}"
fi

# ── 2. chezmoi ──
if ! command -v chezmoi &> /dev/null; then
  echo -e "${GREEN}Installing chezmoi...${NC}"
  brew install chezmoi
else
  echo -e "${GREEN}chezmoi already installed${NC}"
fi

# ── 3. Apply dotfiles configs ──
echo -e "${BLUE}Applying dotfiles...${NC}"
chezmoi init --force --apply --branch "$BRANCH" "$REPO"

# ── 4. Run install scripts directly ──
SCRIPT_DIR="$(chezmoi source-path)/.install-scripts"

echo -e "${BLUE}Running install scripts...${NC}"
source "$SCRIPT_DIR/brew-cli.sh"
source "$SCRIPT_DIR/brew-gui.sh"
source "$SCRIPT_DIR/other-setup.sh"

echo ""
echo -e "${BLUE}╔════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Bootstrap Complete!            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Manual steps:${NC}"
echo "  - Raycast: Launch and set up extensions/hotkeys"
echo "  - Karabiner: System Settings -> Privacy & Security -> Accessibility"
echo "  - Mouseless: System Settings -> Privacy & Security -> Accessibility"
echo "  - Neovim: Launch to auto-install LSP servers via Mason"
echo ""
echo -e "${GREEN}Restart your terminal to apply all changes.${NC}"
