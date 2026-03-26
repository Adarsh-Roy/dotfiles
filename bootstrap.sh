#!/bin/bash
set -euo pipefail

REPO="Adarsh-Roy/dotfiles"
BRANCH="install-script"

export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export NC='\033[0m'

log()  { echo -e "${BLUE}[bootstrap]${NC} $*"; }
ok()   { echo -e "${GREEN}[bootstrap]${NC} $*"; }
warn() { echo -e "${YELLOW}[bootstrap]${NC} $*"; }
err()  { echo -e "${RED}[bootstrap]${NC} $*"; }

log "════════════════════════════════════"
log "  macOS Bootstrap — $REPO"
log "════════════════════════════════════"
log ""

# ── Preflight ──
log "Checking OS..."
if [[ "$OSTYPE" != "darwin"* ]]; then
  err "This script is for macOS only (got $OSTYPE)"
  exit 1
fi
ok "macOS detected ($OSTYPE)"

log "Script directory: $(dirname "$0")"
SCRIPT_DIR="$(dirname "$0")/.install-scripts"
log "Install scripts directory: $SCRIPT_DIR"

if [ ! -d "$SCRIPT_DIR" ]; then
  err "Install scripts directory not found: $SCRIPT_DIR"
  exit 1
fi
ok "Install scripts directory exists"
log ""

# ── 1. Homebrew ──
log "── Step 1/5: Homebrew ──"
if ! command -v brew &> /dev/null; then
  log "Homebrew not found, installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ $(uname -m) == "arm64" ]]; then
    log "Apple Silicon detected, adding brew to PATH..."
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  ok "Homebrew installed"
else
  ok "Homebrew already installed ($(brew --version | head -1))"
fi
log ""

# ── 2. chezmoi ──
log "── Step 2/5: chezmoi ──"
if ! command -v chezmoi &> /dev/null; then
  log "chezmoi not found, installing via brew..."
  brew install chezmoi
  ok "chezmoi installed"
else
  ok "chezmoi already installed ($(chezmoi --version))"
fi
log ""

# ── 3. Apply dotfiles ──
log "── Step 3/5: Apply dotfiles configs ──"
log "Running: chezmoi init --force --apply --branch $BRANCH $REPO"
chezmoi init --force --apply --branch "$BRANCH" "$REPO"
ok "Dotfiles applied"
log ""

# ── 4. Install packages ──
log "── Step 4/5: Install packages ──"

log "Sourcing $SCRIPT_DIR/brew-cli.sh ..."
source "$SCRIPT_DIR/brew-cli.sh"
ok "brew-cli.sh done"
log ""

log "Sourcing $SCRIPT_DIR/brew-gui.sh ..."
source "$SCRIPT_DIR/brew-gui.sh"
ok "brew-gui.sh done"
log ""

# ── 5. Other setup ──
log "── Step 5/5: Other setup ──"

log "Sourcing $SCRIPT_DIR/other-setup.sh ..."
source "$SCRIPT_DIR/other-setup.sh"
ok "other-setup.sh done"
log ""

# ── Done ──
log "════════════════════════════════════"
ok "  Bootstrap complete!"
log "════════════════════════════════════"
log ""
warn "Manual steps:"
warn "  - Raycast: Launch and set up extensions/hotkeys"
warn "  - Karabiner: System Settings -> Privacy & Security -> Accessibility"
warn "  - Mouseless: System Settings -> Privacy & Security -> Accessibility"
warn "  - Neovim: Launch to auto-install LSP servers via Mason"
log ""
ok "Restart your terminal to apply all changes."
