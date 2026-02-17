#!/bin/bash
set -euo pipefail

echo "macOS Bootstrap Script"
echo "=========================="

# Check if macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "ERROR: This script is for macOS only"
  exit 1
fi

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH for Apple Silicon
  if [[ $(uname -m) == "arm64" ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
else
  echo "Homebrew already installed"
fi

# Install chezmoi
if ! command -v chezmoi &> /dev/null; then
  echo "Installing chezmoi..."
  brew install chezmoi
else
  echo "chezmoi already installed"
fi

# Prompt for Git repository URL
echo ""
echo "Enter your dotfiles Git repository URL:"
read -r DOTFILES_REPO

# Initialize chezmoi and apply
echo "Initializing chezmoi and applying dotfiles..."
chezmoi init --apply "$DOTFILES_REPO"

echo ""
echo "Bootstrap complete!"
echo "The installation script will now run automatically."
echo "Please check the output above for any manual steps required."
