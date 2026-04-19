# TUI App Launchers

Single-purpose Kitty windows that behave like dedicated macOS apps (floating, no tab bar, no cmd+t, focus-if-already-running). Triggered by Leader Key chords.

## Add a new TUI

1. Create `~/.config/kitty/apps/<name>.sh`:

   ```bash
   #!/bin/bash
   source "$(dirname "$0")/_launch.sh"
   launch_tui_app <NAME>_TUI_APP -e /bin/zsh -c 'exec /path/to/the/tui [args...]'
   ```

2. `chmod +x ~/.config/kitty/apps/<name>.sh`

3. In Leader Key, map a chord (e.g., `t <letter>`) to run the script.

That's it. No Aerospace changes — the rule in `aerospace.toml` floats anything whose Kitty window title contains `_TUI_APP`.

## What `_launch.sh` does

The shared helper gives every launcher the same native-app UX:

- **If the app is already running**, aerospace focuses the existing window in place — switches you to whichever workspace it lives on. The window is not moved, so the layout on that workspace is preserved.
- **If the app isn't running**, a fresh Kitty window is spawned (floating, current workspace).
- Always prepends `--title` and `--config _app.conf`, so launchers stay one-liners.

## Conventions

- **Window title:** `<NAME>_TUI_APP`, all caps. This is the glue between the launcher and the Aerospace float rule.
- **Script name:** `<name>.sh`, lowercase.
- **Working dir** (optional): add `--directory "$HOME/some/path"` before `-e` to launch the TUI in a specific cwd.

## Optional: per-TUI overrides

If one TUI wants different font size, opacity, dimensions, etc., drop a `<name>.conf` next to the `.sh`:

```conf
include _app.conf

font_size 14
background_opacity 0.9
initial_window_width 130c
```

Then chain configs in the launcher:

```bash
--config "$HOME/.config/kitty/apps/_app.conf" \
--config "$HOME/.config/kitty/apps/<name>.conf" \
```

Later `--config` files override earlier ones.

## Opt-in tabs for a specific TUI

The default is no tabs. If a specific TUI should have tabs (e.g., a scratch terminal where you do want multiple tabs), chain `_tabs.conf` after `_app.conf`:

```bash
--config "$HOME/.config/kitty/apps/_app.conf" \
--config "$HOME/.config/kitty/apps/_tabs.conf" \
```

`_tabs.conf` re-enables the tab bar and `cmd+t` / `cmd+shift+t`.

## Behavior

- Opens floating on the **current** Aerospace workspace (not routed).
- No tab bar, no cmd+t (enforced by `_app.conf`).
- Window closes when the TUI exits — Ctrl-C, `q`, or closing the window all work.
- Each launch is a fresh Kitty process. No session persistence between launches.

## Examples

- `btop.sh` — minimal launcher, no custom dir.
- `claude.sh` — Claude Code with cwd, model, effort, and permission-mode flags.
