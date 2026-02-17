#!/bin/bash
# Module: Homebrew CLI Tools (macOS only)

[[ "$OSTYPE" != "darwin"* ]] && echo "brew-cli.sh: skipping (not macOS)" && return 0

echo -e "${GREEN}Installing Homebrew CLI tools...${NC}"

brew bundle --no-lock --file=/dev/stdin <<EOF
# Taps
tap "felixkratz/formulae"

# Version Control
brew "git"
brew "git-lfs"
brew "git-delta"
brew "lazygit"

# Editors
brew "neovim"

# CLI Utilities
brew "yazi"
brew "zoxide"

# Window Management (CLI companion for Borders)
brew "felixkratz/formulae/borders"
EOF

echo -e "${GREEN}Homebrew CLI tools installed${NC}\n"
