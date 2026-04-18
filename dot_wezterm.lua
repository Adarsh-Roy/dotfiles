local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Lazy workspace layouts — spawned only the first time you switch in, not at startup.
local function spawn_workspace_layout(name, tabs_spec)
	local first_tab, first_pane, mux_win = wezterm.mux.spawn_window({ workspace = name })
	first_tab:set_title(tabs_spec[1].title)
	if tabs_spec[1].cmd then first_pane:send_text(tabs_spec[1].cmd .. "\n") end
	for i = 2, #tabs_spec do
		local t, p, _ = mux_win:spawn_tab({})
		t:set_title(tabs_spec[i].title)
		if tabs_spec[i].cmd then p:send_text(tabs_spec[i].cmd .. "\n") end
	end
	first_tab:activate()
end

local workspace_layouts = {}
if wezterm.target_triple:find("apple%-darwin") then
	workspace_layouts["notes-dragonfruit"] = function()
		spawn_workspace_layout("notes-dragonfruit", {
			{ title = "nvim", cmd = "open-df-notes" },
		})
	end
	workspace_layouts["notes-professional"] = function()
		spawn_workspace_layout("notes-professional", {
			{ title = "nvim", cmd = "open-pro-notes" },
		})
	end
	workspace_layouts["df-services"] = function()
		spawn_workspace_layout("df-services", {
			{ title = "nvim",   cmd = "open-df-services" },
			{ title = "claude", cmd = "open-df-services" },
			{ title = "server", cmd = "open-df-services" },
			{ title = "db",     cmd = "open-df-services; make create-services-db; make connect-to-services-db" },
			{ title = "alem",   cmd = "open-df-services" },
			{ title = "term",   cmd = "open-df-services" },
		})
	end
	workspace_layouts["ml-scripts"] = function()
		spawn_workspace_layout("ml-scripts", {
			{ title = "nvim", cmd = "cd ~/Dragonfruit/DF_Repos/df-clm-scripts" },
		})
	end
	workspace_layouts["ml-validation-tools"] = function()
		spawn_workspace_layout("ml-validation-tools", {
			{ title = "nvim", cmd = "cd ~/Dragonfruit/DF_Repos/df-validation-tools" },
		})
	end
	workspace_layouts["df-common"] = function()
		spawn_workspace_layout("df-common", {
			{ title = "nvim", cmd = "open-df-common" },
			{ title = "term", cmd = "open-df-common" },
		})
	end
	workspace_layouts["df-client"] = function()
		spawn_workspace_layout("df-client", {
			{ title = "nvim", cmd = "cd ~/Dragonfruit/DF_Repos/df-client" },
			{ title = "term", cmd = "cd ~/Dragonfruit/DF_Repos/df-client" },
		})
	end
	workspace_layouts["transport-service"] = function()
		spawn_workspace_layout("transport-service", {
			{ title = "nvim", cmd = "open-transport-service" },
			{ title = "term", cmd = "open-transport-service" },
		})
	end
end

-- Helper functions for workspace switching with history tracking
local function switch_workspace(window, pane, workspace)
	local current_workspace = window:active_workspace()
	if current_workspace == workspace then
		return
	end

	-- Spawn this workspace's layout the first time we visit it
	local exists = false
	for _, ws in ipairs(wezterm.mux.get_workspace_names()) do
		if ws == workspace then
			exists = true
			break
		end
	end
	if not exists and workspace_layouts[workspace] then
		workspace_layouts[workspace]()
	end

	window:perform_action(
		wezterm.action.SwitchToWorkspace({
			name = workspace,
		}),
		pane
	)

	wezterm.GLOBAL.previous_workspace = current_workspace
end

local function switch_to_previous_workspace(window, pane)
	local current_workspace = window:active_workspace()
	local workspace = wezterm.GLOBAL.previous_workspace

	if current_workspace == workspace or wezterm.GLOBAL.previous_workspace == nil then
		return
	end

	switch_workspace(window, pane, workspace)
end

-- Kill every pane in a workspace. Switches away first if we're currently in it.
-- Uses `wezterm cli kill-pane` with absolute path — wezterm's GUI children don't
-- inherit shell PATH on macOS, so bare "wezterm" would silently fail to launch.
local wezterm_bin = "/opt/homebrew/bin/wezterm"
local function kill_workspace(window, pane, target)
	if window:active_workspace() == target then
		local go_to = wezterm.GLOBAL.previous_workspace
		if go_to == nil or go_to == target then go_to = "default" end
		switch_workspace(window, pane, go_to)
	end

	for _, mux_win in ipairs(wezterm.mux.all_windows()) do
		if mux_win:get_workspace() == target then
			for _, tab in ipairs(mux_win:tabs()) do
				for _, p in ipairs(tab:panes()) do
					local ok, _, stderr = wezterm.run_child_process({
						wezterm_bin, "cli", "kill-pane",
						"--pane-id", tostring(p:pane_id()),
					})
					if not ok then
						wezterm.log_error("kill-pane failed: " .. (stderr or ""))
					end
				end
			end
		end
	end
end

local function setup_font(cfg)
	cfg.font = wezterm.font_with_fallback({
		"Maple Mono NF",
		"JetBrains Mono",
		"Symbols Nerd Font Mono",
		"Noto Color Emoji",
	})
	cfg.font_size = 17
end

local function setup_colors(cfg)
	cfg.colors = {
		foreground = "#CBE0F0",
		background = "#000000",
		cursor_bg = "#47FF9C",
		cursor_border = "#47FF9C",
		cursor_fg = "#011423",
		selection_bg = "#3A3F4B",
		selection_fg = "#DCDFE4",
		ansi = {
			"#282C34",
			"#E52E2E",
			"#44FFB1",
			"#FFE073",
			"#0FC5ED",
			"#A277FF",
			"#24EAF7",
			"#24EAF7",
		},
		brights = {
			"#282C34",
			"#E52E2E",
			"#44FFB1",
			"#FFE073",
			"#A277FF",
			"#A277FF",
			"#24EAF7",
			"#24EAF7",
		},
		tab_bar = {
			background = "#000000",

			active_tab = {
				bg_color = "#282C34",
				fg_color = "#DCDFE4",
				intensity = "Bold",
			},

			inactive_tab = {
				bg_color = "#000000",
				fg_color = "#666666",
			},

			inactive_tab_hover = {
				bg_color = "#282C34",
				fg_color = "#FFFFFF",
				italic = true,
			},
		},
	}
end

local function setup_tabs_status(cfg)
	cfg.use_fancy_tab_bar = false

	local LEFT_ARROW = ""
	local RIGHT_ARROW = ""

	-- Format the individual tab
	local function fancy_tab_format(tab, tabs, panes, config, hover, max_width)
		local active_bg = config.colors.tab_bar.active_tab.bg_color
		local active_fg = config.colors.tab_bar.active_tab.fg_color
		local inactive_bg = config.colors.tab_bar.inactive_tab.bg_color
		local inactive_fg = config.colors.tab_bar.inactive_tab.fg_color

		local title = tab.tab_title
		if not title or #title == 0 then
			title = tab.active_pane.title or ""
		end
		if #title > max_width - 3 then
			title = title:sub(1, max_width - 3) .. "…"
		end

		local tab_number = tab.tab_index
		title = string.format("%d | %s", tab_number, title)

		if tab.is_active then
			-- Active tab
			return {
				{ Background = { Color = config.colors.tab_bar.background } },
				{ Foreground = { Color = active_bg } },
				{ Text = LEFT_ARROW },

				{ Background = { Color = active_bg } },
				{ Foreground = { Color = active_fg } },
				{ Text = " " .. title .. " " },

				{ Background = { Color = config.colors.tab_bar.background } },
				{ Foreground = { Color = active_bg } },
				{ Text = RIGHT_ARROW },
			}
		else
			-- Inactive tab
			return {
				{ Background = { Color = config.colors.tab_bar.background } },
				{ Foreground = { Color = inactive_bg } },
				{ Text = LEFT_ARROW },

				{ Background = { Color = inactive_bg } },
				{ Foreground = { Color = inactive_fg } },
				{
					-- No italic; just make it a bit bolder if hovered
					Attribute = { Intensity = hover and "Bold" or "Normal" },
				},
				{ Text = " " .. title .. " " },

				{ Background = { Color = config.colors.tab_bar.background } },
				{ Foreground = { Color = inactive_bg } },
				{ Text = RIGHT_ARROW },
			}
		end
	end

	wezterm.on("format-tab-title", fancy_tab_format)

	-- Place the workspace name on the right in a matching rounded style
	wezterm.on("update-status", function(window, _)
		local active_bg = cfg.colors.tab_bar.active_tab.bg_color
		local active_fg = cfg.colors.tab_bar.active_tab.fg_color
		local workspace = window:active_workspace()

		local right_status = {
			{ Background = { Color = config.colors.tab_bar.background } },
			{ Foreground = { Color = active_bg } },
			{ Text = LEFT_ARROW },

			{ Background = { Color = active_bg } },
			{ Foreground = { Color = active_fg } },
			{ Text = " " .. workspace .. " " },

			{ Background = { Color = active_bg } },
			{ Foreground = { Color = active_bg } },
			{ Text = RIGHT_ARROW },
		}

		window:set_right_status(wezterm.format(right_status))
	end)

	-- Show thunder emoji on the left when the leader key is active
	wezterm.on("update-status", function(window, _)
		-- We'll only set the LEFT status here
		local SOLID_LEFT_ARROW = ""
		local ARROW_FOREGROUND = { Foreground = { Color = "#CBE0F0" } }
		local prefix = ""

		if window:leader_is_active() or window:active_key_table() then
			prefix = " " .. utf8.char(0x26A1)
			SOLID_LEFT_ARROW = utf8.char(0xe0b2)
		end

		-- Optional: color shift if not tab_id 0
		if window:active_tab():tab_id() ~= 0 then
			ARROW_FOREGROUND = { Foreground = { Color = "#1e2030" } }
		end

		window:set_left_status(wezterm.format({
			{ Background = { Color = "#011423" } },
			{ Text = prefix },
			ARROW_FOREGROUND,
			{ Text = SOLID_LEFT_ARROW },
		}))
	end)
end

local function setup_keys(cfg)
	-- Powershell as default in windows
	if wezterm.target_triple == "x86_64-pc-windows-msvc" then
		cfg.default_prog = { "powershell.exe" }
	end

	cfg.keys = {}

	-- Leader key
	if wezterm.target_triple:find("apple%-darwin") then
		cfg.leader = { key = "d", mods = "CMD", timeout_milliseconds = 2000 }
	else
		cfg.leader = { key = "d", mods = "CTRL", timeout_milliseconds = 2000 }
	end

	-- Define key mappings
	local key_maps = {
		{ key = " ",          mods = "LEADER", action = wezterm.action.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
		{ key = "n",          mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
		{ key = "Enter",      mods = "LEADER", action = wezterm.action.ActivateCopyMode },
		{ key = "T",          mods = "LEADER", action = wezterm.action.ToggleAlwaysOnTop },
		{ key = "h",          mods = "CMD",    action = wezterm.action.ActivateTabRelative(-1) },
		{ key = "l",          mods = "CMD",    action = wezterm.action.ActivateTabRelative(1) },
		{ key = 'H',          mods = 'LEADER', action = wezterm.action.MoveTabRelative(-1) },
		{ key = 'L',          mods = 'LEADER', action = wezterm.action.MoveTabRelative(1) },
		{ key = "|",          mods = "LEADER", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "-",          mods = "LEADER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "h",          mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Left") },
		{ key = "j",          mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Down") },
		{ key = "k",          mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Up") },
		{ key = "l",          mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Right") },
		{ key = "LeftArrow",  mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Left", 5 }) },
		{ key = "RightArrow", mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Right", 5 }) },
		{ key = "UpArrow",    mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Up", 5 }) },
		{ key = "DownArrow",  mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Down", 5 }) },
		-- Toggle between current and previous tab (within workspace)
		{
			key = "Tab",
			mods = "LEADER",
			action = wezterm.action.ActivateLastTab,
		},
		-- Toggle between current and previous workspace
		{
			key = "Tab",
			mods = "LEADER|SHIFT",
			action = wezterm.action_callback(function(window, pane)
				switch_to_previous_workspace(window, pane)
			end),
		},
		-- create a new named workspace
		{
			key = "N",
			mods = "LEADER",
			action = wezterm.action.PromptInputLine {
				description = "Enter name for new workspace",
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						window:perform_action(
							wezterm.action.SwitchToWorkspace({ name = line }),
							pane
						)
					end
				end),
			},
		},
		-- rename current workspace
		{
			key = "R",
			mods = "LEADER",
			action = wezterm.action.PromptInputLine {
				description = "Enter new name for workspace",
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						wezterm.mux.rename_workspace(
							wezterm.mux.get_active_workspace(),
							line
						)
					end
				end),
			},
		},
		-- kill current workspace (with Y/N confirmation)
		{
			key = "X",
			mods = "LEADER",
			action = wezterm.action_callback(function(window, pane)
				local target = window:active_workspace()
				local prompt = "Kill workspace '" .. target .. "' ?"
				local yes_label = wezterm.format({
					{ Foreground = { AnsiColor = "Red" } },
					{ Text = "[Y]" },
					"ResetAttributes",
					{ Text = "es" },
				})
				local no_label = "[N]o"
				window:perform_action(
					wezterm.action.InputSelector({
						title = prompt,
						description = prompt,
						fuzzy_description = prompt,
						alphabet = "ny",
						choices = {
							{ label = no_label,  id = "no" },
							{ label = yes_label, id = "yes" },
						},
						action = wezterm.action_callback(function(win, p, id, _label)
							if id == "yes" then
								kill_workspace(win, p, target)
							end
						end),
					}),
					pane
				)
			end),
		},
		-- use a key table: leader + "w" activates the workspace table.
		{
			key = "w",
			mods = "LEADER",
			action = wezterm.action.ActivateKeyTable({ name = "workspace", timeout_milliseconds = 2000 }),
		},
		{
			key = "r",
			mods = "LEADER",
			action = wezterm.action.PromptInputLine({
				description = "Enter new name for tab",
				action = wezterm.action_callback(function(window, _pane, line)
					if line then
						window:active_tab():set_title(line)
					end
				end),
			}),
		},
	}

	for _, km in ipairs(key_maps) do
		table.insert(cfg.keys, km)
	end

	-- Number-based tab switching (Leader + 0-9)
	for i = 0, 9 do
		table.insert(cfg.keys, {
			key = tostring(i),
			mods = "LEADER",
			action = wezterm.action.ActivateTab(i),
		})
	end

	-- Font size via Leader (OS-agnostic)
	table.insert(cfg.keys, { key = "f", mods = "LEADER", action = wezterm.action.ResetFontSize })

	-- Define key tables for multi-key sequences.
	-- Apple configuration
	if wezterm.target_triple:find("apple%-darwin") then
		cfg.key_tables = {
			workspace = {
				{
					key = "b",
					action = wezterm.action_callback(function(window, pane)
						switch_workspace(window, pane, "df-services")
					end),
				},
				{
					key = "c",
					action = wezterm.action_callback(function(window, pane)
						switch_workspace(window, pane, "df-common")
					end),
				},
				{
					key = "f",
					action = wezterm.action_callback(function(window, pane)
						switch_workspace(window, pane, "df-client")
					end),
				},
				{
					key = "t",
					action = wezterm.action.ActivateKeyTable({
						name = "workspace_transport",
						timeout_milliseconds = 2000,
					}),
				},
				{
					key = "n",
					action = wezterm.action.ActivateKeyTable({
						name = "workspace_notes",
						timeout_milliseconds = 2000,
					}),
				},
				{
					key = "m",
					action = wezterm.action.ActivateKeyTable({
						name = "workspace_ml",
						timeout_milliseconds = 2000,
					}),
				},
				{ key = "Escape", action = wezterm.action.PopKeyTable },
			},
			workspace_transport = {
				{
					key = "s",
					action = wezterm.action_callback(function(window, pane)
						switch_workspace(window, pane, "transport-service")
					end),
				},
				{ key = "Escape", action = wezterm.action.PopKeyTable },
			},
			workspace_notes = {
				{
					key = "d",
					action = wezterm.action_callback(function(window, pane)
						switch_workspace(window, pane, "notes-dragonfruit")
					end),
				},
				{
					key = "p",
					action = wezterm.action_callback(function(window, pane)
						switch_workspace(window, pane, "notes-professional")
					end),
				},
				{ key = "Escape", action = wezterm.action.PopKeyTable },
			},
			workspace_ml = {
				{
					key = "s",
					action = wezterm.action_callback(function(window, pane)
						switch_workspace(window, pane, "ml-scripts")
					end),
				},
				{
					key = "v",
					action = wezterm.action_callback(function(window, pane)
						switch_workspace(window, pane, "ml-validation-tools")
					end),
				},
				{ key = "Escape", action = wezterm.action.PopKeyTable },
			},
		}
	end

	-- default workspaces with no tabs or pans configuration
	cfg.key_tables = cfg.key_tables or { workspace = {} }
	for i = 1, 4 do
		table.insert(cfg.key_tables.workspace, {
			key = tostring(i),
			action = wezterm.action_callback(function(window, pane)
				switch_workspace(window, pane, "WS" .. tostring(i))
			end),
		})
	end
	table.insert(cfg.key_tables.workspace, {
		key = "d",
		action = wezterm.action_callback(function(window, pane)
			switch_workspace(window, pane, "default")
		end),
	})
end

local function setup_window(cfg)
	cfg.window_decorations = "RESIZE"
	cfg.window_background_opacity = 0.80
	cfg.macos_window_background_blur = 13
	-- cfg.win32_system_backdrop = "Acrylic"
	cfg.enable_tab_bar = true
	cfg.hide_tab_bar_if_only_one_tab = false
	cfg.tab_and_split_indices_are_zero_based = true

	cfg.max_fps = 120
end

local function setup_gui_startup()
	wezterm.on("gui-startup", function()
		local mux = wezterm.mux
		mux.spawn_window({ workspace = "default" })
		mux.set_active_workspace("default")
	end)
end

setup_font(config)
setup_colors(config)
setup_tabs_status(config)
setup_keys(config)
setup_window(config)
setup_gui_startup()

config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false
-- disable wayland unless the error is fixed
config.enable_wayland = false
return config
