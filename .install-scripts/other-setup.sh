#!/bin/bash
# Module: Other Setup (Shell, Services, etc.) - macOS only

[[ "$OSTYPE" != "darwin"* ]] && echo "other-setup.sh: skipping (not macOS)" && return 0

echo -e "${GREEN}Running other setup tasks...${NC}"

# Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo -e "${GREEN}  Installing Oh My Zsh...${NC}"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo -e "${GREEN}  Oh My Zsh already installed${NC}"
fi

# Powerlevel10k theme
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  echo -e "${GREEN}  Installing Powerlevel10k theme...${NC}"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
  echo -e "${GREEN}  Powerlevel10k already installed${NC}"
fi

# Git LFS
echo -e "${GREEN}  Configuring Git LFS...${NC}"
git lfs install

# Start brew services
echo -e "${GREEN}  Starting brew services...${NC}"
brew services start aerospace 2>/dev/null || true
brew services start borders 2>/dev/null || true

echo -e "${GREEN}Other setup complete${NC}\n"
