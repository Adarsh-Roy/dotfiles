# dotfiles

Managed with [chezmoi](https://chezmoi.io). Dotfiles work cross-platform (macOS and Linux) with OS-specific configs handled via chezmoi templates — e.g. aerospace/karabiner/borders on macOS, hyprland on Linux. The install script is macOS-only.

## One-liner setup (macOS)

```
curl -fsSL https://raw.githubusercontent.com/Adarsh-Roy/dotfiles/main/bootstrap.sh | bash
```

Paste that into Terminal on a fresh Mac. It handles everything:
- Installs Homebrew (skips if present)
- Installs chezmoi (skips if present)
- Clones dotfiles and applies configs
- Installs core CLI tools (git, neovim, yazi, zoxide, lazygit, borders)
- Installs core GUI apps (wezterm, aerospace, karabiner, raycast, leader-key, mouseless)
- Prompts for optional apps (slack, chrome, spotify, etc.)
- Sets up oh-my-zsh + powerlevel10k

Everything is idempotent — safe to run again on a machine that already has some or all of this installed.

## Linux / manual setup

Install chezmoi and apply the dotfiles directly:

```
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply Adarsh-Roy/dotfiles
```

OS-specific configs are automatically included/excluded via `.chezmoiignore`.
