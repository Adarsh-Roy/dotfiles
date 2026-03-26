#!/bin/bash
# Module: Other Setup (Shell, Services, etc.) - macOS only

[[ "$OSTYPE" != "darwin"* ]] && echo -e "${YELLOW}[setup] skipping (not macOS)${NC}" && return 0

echo -e "${BLUE}[setup]${NC} Running other setup tasks..."

# Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo -e "${BLUE}[setup]${NC} Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  echo -e "${GREEN}[setup]${NC} Oh My Zsh installed"
else
  echo -e "${GREEN}[setup]${NC} Oh My Zsh already installed"
fi

# Powerlevel10k theme
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  echo -e "${BLUE}[setup]${NC} Installing Powerlevel10k theme..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
  echo -e "${GREEN}[setup]${NC} Powerlevel10k installed"
else
  echo -e "${GREEN}[setup]${NC} Powerlevel10k already installed"
fi

# Git LFS
echo -e "${BLUE}[setup]${NC} Configuring Git LFS..."
git lfs install
echo -e "${GREEN}[setup]${NC} Git LFS configured"

# Start brew services
echo -e "${BLUE}[setup]${NC} Starting aerospace service..."
brew services start aerospace 2>/dev/null || true
echo -e "${BLUE}[setup]${NC} Starting borders service..."
brew services start borders 2>/dev/null || true
echo -e "${GREEN}[setup]${NC} Brew services started"

echo -e "${GREEN}[setup]${NC} All setup tasks complete"
