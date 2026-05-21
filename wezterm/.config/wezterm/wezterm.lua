-- Load the WezTerm API and configuration builder
local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Theme and colors
config.colors = {
	foreground = "#D8DEE9",
	background = "#10151F",
	cursor_bg = "#FFB86C",
	cursor_border = "#FFB86C",
	cursor_fg = "#10151F",
	selection_bg = "#2E405C",
	selection_fg = "#F4F6FA",
	split = "#3B4658",
	compose_cursor = "#8BE9FD",

	ansi = {
		"#1A2230",
		"#FF6B7A",
		"#7BD88F",
		"#F4D06F",
		"#6CB6FF",
		"#C792EA",
		"#5DE4C7",
		"#D8DEE9",
	},

	brights = {
		"#56657A",
		"#FF8A95",
		"#9AE6AA",
		"#FFE08A",
		"#8CCBFF",
		"#D6A8FF",
		"#82F7DD",
		"#F8FAFC",
	},

	tab_bar = {
		background = "#10151F",

		active_tab = {
			bg_color = "#263244",
			fg_color = "#F8FAFC",
			intensity = "Bold",
		},

		inactive_tab = {
			bg_color = "#182131",
			fg_color = "#8E9AAF",
		},

		inactive_tab_hover = {
			bg_color = "#202B3D",
			fg_color = "#D8DEE9",
		},

		new_tab = {
			bg_color = "#182131",
			fg_color = "#8E9AAF",
		},

		new_tab_hover = {
			bg_color = "#202B3D",
			fg_color = "#D8DEE9",
		},
	},
}

-- Font configuration
config.font = wezterm.font {
	family = "JetBrainsMono Nerd Font Mono",
	harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
}
config.font_size = 12.5

-- Window configuration
config.enable_tab_bar = false
config.window_decorations = "TITLE | RESIZE"

-- Cursor configuration
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500

-- Background opacity
config.window_background_opacity = 0.9

-- Keep more terminal history
config.scrollback_lines = 10000

-- Start WezTerm in a default working directory
config.default_cwd = os.getenv("HOME") or "."

-- Default shell
config.default_prog = { "zsh" }

-- Word boundary characters for text selection
config.selection_word_boundary = " \t\n{}[]()\"'`,;:"

-- Custom launcher entries
config.launch_menu = {
	{
		label = "Zsh",
		args = { "zsh" },
	},
	{
		label = "Bash",
		args = { "bash" },
	},
	{
		label = "Htop",
		args = { "htop" },
	},
}

-- Key bindings
config.keys = {
-- Delete one word backward
{
	key = "Backspace",
	mods = "CTRL",
	action = wezterm.action.SendString "\x17",
},

	-- Copy selected text to the system clipboard
	{
		key = "C",
		mods = "CTRL|SHIFT",
		action = wezterm.action.CopyTo "Clipboard",
	},

	-- Paste text from the system clipboard
	{
		key = "V",
		mods = "CTRL|SHIFT",
		action = wezterm.action.PasteFrom "Clipboard",
	},

	-- Open the command palette
	{
		key = "P",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivateCommandPalette,
	},

	-- Quickly select URLs, paths, hashes, and other common patterns
	{
		key = "Space",
		mods = "CTRL|SHIFT",
		action = wezterm.action.QuickSelect,
	},

	-- Enter keyboard-based copy mode
	{
		key = "X",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivateCopyMode,
	},

	-- Open launcher menu
	{
		key = "L",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ShowLauncher,
	},

	-- Split to the right
	{
		key = "\\",
		mods = "ALT",
		action = wezterm.action.SplitPane {
			direction = "Right",
			size = { Percent = 50 },
		},
	},

	-- Split to the left
	{
		key = "\\",
		mods = "ALT|SHIFT",
		action = wezterm.action.SplitPane {
			direction = "Left",
			size = { Percent = 50 },
		},
	},

	-- Split to the bottom
	{
		key = "-",
		mods = "ALT",
		action = wezterm.action.SplitPane {
			direction = "Down",
			size = { Percent = 50 },
		},
	},

	-- Split to the top
	{
		key = "-",
		mods = "ALT|SHIFT",
		action = wezterm.action.SplitPane {
			direction = "Up",
			size = { Percent = 50 },
		},
	},

	-- Move focus to the left pane
	{
		key = "LeftArrow",
		mods = "ALT",
		action = wezterm.action.ActivatePaneDirection "Left",
	},

	-- Move focus to the right pane
	{
		key = "RightArrow",
		mods = "ALT",
		action = wezterm.action.ActivatePaneDirection "Right",
	},

	-- Move focus to the upper pane
	{
		key = "UpArrow",
		mods = "ALT",
		action = wezterm.action.ActivatePaneDirection "Up",
	},

	-- Move focus to the lower pane
	{
		key = "DownArrow",
		mods = "ALT",
		action = wezterm.action.ActivatePaneDirection "Down",
	},

	-- Select a pane by label
	{
		key = "p",
		mods = "ALT",
		action = wezterm.action.PaneSelect {
			mode = "Activate",
		},
	},

	-- Swap current pane with another pane
	{
		key = "P",
		mods = "ALT|SHIFT",
		action = wezterm.action.PaneSelect {
			mode = "SwapWithActive",
		},
	},

	-- Resize pane to the left
	{
		key = "h",
		mods = "ALT|SHIFT",
		action = wezterm.action.AdjustPaneSize { "Left", 5 },
	},

	-- Resize pane to the right
	{
		key = "l",
		mods = "ALT|SHIFT",
		action = wezterm.action.AdjustPaneSize { "Right", 5 },
	},

	-- Resize pane upward
	{
		key = "k",
		mods = "ALT|SHIFT",
		action = wezterm.action.AdjustPaneSize { "Up", 5 },
	},

	-- Resize pane downward
	{
		key = "j",
		mods = "ALT|SHIFT",
		action = wezterm.action.AdjustPaneSize { "Down", 5 },
	},

	-- Toggle zoom for the current pane
	{
		key = "Enter",
		mods = "ALT",
		action = wezterm.action.TogglePaneZoomState,
	},

	-- Close the current pane
	{
		key = "w",
		mods = "ALT",
		action = wezterm.action.CloseCurrentPane { confirm = true },
	},
}

-- Return the final configuration
return config
