# dotfiles

Managed with [chezmoi](https://chezmoi.io). macOS only.

## One-liner setup

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
