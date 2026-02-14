local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local mux = wezterm.mux
local act = wezterm.action

-- Always return "FLOATING_NOTES" as the window title, regardless of what Neovim sets
wezterm.on('format-window-title', function()
	return "FLOATING_NOTES"
end)

-- Force "Always On Top" and position on right side of screen on startup
wezterm.on('gui-startup', function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	local gui = window:gui_window()
	gui:perform_action(act.ToggleAlwaysOnTop, pane)

	-- Position on the right side of the active screen
	local screen = wezterm.gui.screens().active
	local dims = gui:get_dimensions()
	local x = screen.x + screen.width - dims.pixel_width - 40
	local y = screen.y + 60
	gui:set_position(x, y)
end)

config.default_cwd = "/Users/adarsh/Obsidian/Dragonfruit/DragonfruitVault"

config.default_prog = {
	"/opt/homebrew/bin/nvim",
	"--listen", "/tmp/nvim-floating-socket",
	"-c", "Obsidian today"
}

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.95
config.initial_cols = 55
config.initial_rows = 45
config.exit_behavior = "Close"
config.enable_tab_bar = false

return config
