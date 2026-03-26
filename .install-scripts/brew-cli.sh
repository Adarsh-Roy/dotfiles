#!/bin/bash
# Module: Homebrew CLI Tools (macOS only)

[[ "$OSTYPE" != "darwin"* ]] && echo -e "${YELLOW}[brew-cli] skipping (not macOS)${NC}" && return 0

echo -e "${BLUE}[brew-cli]${NC} Installing Homebrew CLI tools..."
echo -e "${BLUE}[brew-cli]${NC} Packages: git, git-lfs, git-delta, lazygit, neovim, yazi, zoxide, borders"

brew bundle --verbose --file=/dev/stdin <<EOF
tap "felixkratz/formulae"
brew "git"
brew "git-lfs"
brew "git-delta"
brew "lazygit"
brew "neovim"
brew "yazi"
brew "zoxide"
brew "felixkratz/formulae/borders"
EOF

echo -e "${GREEN}[brew-cli]${NC} All CLI tools installed"
