local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Helper functions for workspace switching with history tracking
local function switch_workspace(window, pane, workspace)
	local current_workspace = window:active_workspace()
	if current_workspace == workspace then
		return
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
		-- Base UI colors
		foreground = "#DCDFE4",
		background = "#000000",
		cursor_bg = "#47FF9C", -- keep your neon cursor
		cursor_border = "#47FF9C",
		cursor_fg = "#000000",

		-- Selection: dark grey background, light text
		selection_bg = "#3A3F4B",
		selection_fg = "#DCDFE4",

		-- One Half Black ANSI palette
		ansi = {
			"#282C34", -- black
			"#E06C75", -- red
			"#98C379", -- green
			"#E5C07B", -- yellow
			"#61AFEF", -- blue
			"#C678DD", -- magenta
			"#56B6C2", -- cyan
			"#DCDFE4", -- white
		},
		brights = {
			"#282C34", -- bright black
			"#E06C75", -- bright red
			"#98C379", -- bright green
			"#E5C07B", -- bright yellow
			"#61AFEF", -- bright blue
			"#C678DD", -- bright magenta
			"#56B6C2", -- bright cyan
			"#DCDFE4", -- bright white
		},

		-- Tab bar tuned for a black theme
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
		{ key = "h",          mods = "CMD",    action = wezterm.action.ActivateTabRelative(-1) },
		{ key = "l",          mods = "CMD",    action = wezterm.action.ActivateTabRelative(1) },
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
		-- Toggle between current and previous workspace
		{
			key = "Tab",
			mods = "LEADER",
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
	cfg.window_background_opacity = 0.83
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

		-- Create "default" workspace
		local default_tab, default_pane, default_window = mux.spawn_window({ workspace = "default" })

		if wezterm.target_triple:find("apple%-darwin") then
			-- Create "notes-dragonfruit" workspace
			local df_notes_tab, df_notes_pane, df_notes_window = mux.spawn_window({ workspace = "notes-dragonfruit" })
			df_notes_pane:send_text("open-df-notes\n")
			df_notes_tab:set_title("nvim")

			-- Create "notes-professional" workspace
			local professional_notes_tab, professional_notes_pane, professional_notes_window =
					mux.spawn_window({ workspace = "notes-professional" })
			professional_notes_pane:send_text("open-pro-notes\n")
			professional_notes_tab:set_title("nvim")

			-- Create "df-services" workspace
			local services_tab, services_pane, services_window = mux.spawn_window({ workspace = "df-services" })
			services_pane:send_text("open-df-services\n")
			services_tab:set_title("nvim")

			local services_server_tab, services_server_pane, _ = services_window:spawn_tab({})
			services_server_pane:send_text("open-df-services\n")
			services_server_tab:set_title("server")

			local services_db_tab, services_db_pane, _ = services_window:spawn_tab({})
			services_db_pane:send_text("open-df-services; make create-services-db; make connect-to-services-db\n")
			services_db_tab:set_title("db")

			local services_alem_tab, services_alem_pane, _ = services_window:spawn_tab({})
			services_alem_pane:send_text("open-df-services\n")
			services_alem_tab:set_title("alem")

			local services_term_tab, services_term_pane, _ = services_window:spawn_tab({})
			services_term_pane:send_text("open-df-services\n")
			services_term_tab:set_title("term")

			services_tab:activate()

			-- Create "ml-scripts" workspace
			local ml_scripts_tab, ml_scripts_pane, ml_scripts_window = mux.spawn_window({ workspace = "ml-scripts" })
			ml_scripts_pane:send_text("cd ~/Desktop/DF_Repos/df-clm-scripts\n")
			ml_scripts_tab:set_title("nvim")

			-- Create "ml-scripts" workspace
			local ml_validation_tools_tab, ml_validation_tools_pane, ml_validation_tools_window =
					mux.spawn_window({ workspace = "ml-validation-tools" })
			ml_validation_tools_pane:send_text("cd ~/Desktop/DF_Repos/df-validation-tools\n")
			ml_validation_tools_tab:set_title("nvim")

			-- Create "df-common" workspace
			local common_tab, common_pane, common_window = mux.spawn_window({ workspace = "df-common" })
			common_pane:send_text("open-df-common\n")
			common_tab:set_title("nvim")

			local common_term_tab, common_term_pane, _ = common_window:spawn_tab({})
			common_term_pane:send_text("open-df-common\n")
			common_term_tab:set_title("term")

			common_tab:activate()

			-- Create "df-client" workspace
			local client_tab, client_pane, client_window = mux.spawn_window({ workspace = "df-client" })
			client_pane:send_text("cd ~/Desktop/DF_Repos/df-client\n")
			client_tab:set_title("nvim")

			local client_term_tab, client_term_pane, _ = client_window:spawn_tab({})
			client_term_pane:send_text("cd ~/Desktop/DF_Repos/df-client\n")
			client_term_tab:set_title("term")

			client_tab:activate()

			-- Create "transport-service" workspace
			local transport_service_tab, transport_service_pane, transport_service_window =
					mux.spawn_window({ workspace = "transport-service" })
			transport_service_pane:send_text("open-transport-service\n")
			transport_service_tab:set_title("nvim")

			local transport_service_term_tab, transport_service_term_pane, _ = transport_service_window:spawn_tab({})
			transport_service_term_pane:send_text("open-transport-service\n")
			transport_service_term_tab:set_title("term")

			transport_service_tab:activate()
		end

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
