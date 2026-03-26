#!/bin/bash
set -euo pipefail

REPO="Adarsh-Roy/dotfiles"

echo "macOS Bootstrap — $REPO"
echo "=========================="

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "ERROR: This script is for macOS only"
  exit 1
fi

# Homebrew
if ! command -v brew &> /dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ $(uname -m) == "arm64" ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
else
  echo "Homebrew already installed"
fi

# chezmoi init + apply (installs chezmoi if needed)
echo "Applying dotfiles..."
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --force --apply --branch install-script "$REPO"

echo ""
echo "Bootstrap complete! Restart your terminal to apply all changes."
