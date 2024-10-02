-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

config.color_scheme = "Catppuccin Frappe"
-- config.color_scheme = "Catppuccin Macchiato"
-- config.color_scheme = "Kanagawa (Gogh)"

config.font = wezterm.font("JetBrainsMono Nerd Font Mono")
config.font_size = 13
config.line_height = 1.2

config.enable_tab_bar = false
config.use_fancy_tab_bar = false
-- config.window_decorations = "TITLE | RESIZE"
config.window_decorations = "RESIZE"

-- config.window_background_opacity = 0.95
-- config.macos_window_background_blur = 10000

config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

config.font_rules = {
	{
		intensity = "Bold",
		italic = false,
		font = wezterm.font("JetBrainsMono Nerd Font Mono", { weight = "Bold", stretch = "Normal", style = "Normal" }),
	},
	{
		intensity = "Bold",
		italic = true,
		font = wezterm.font("JetBrainsMono Nerd Font Mono", { weight = "Bold", stretch = "Normal", style = "Italic" }),
	},
}

-- keep adding configuration options here
--

config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

-- Function to set window size and position
local function set_window_size_and_position(window)
	local screen = wezterm.gui.screens().active
	local scaleFactor = 0.8
	local aspectRatio = 1
	local width, height = screen.width * scaleFactor / aspectRatio, screen.height * scaleFactor
	window:gui_window():set_inner_size(width, height)
	window:gui_window():set_position((screen.width - width) / 2, (screen.height - height) / 2)
end

-- Apply the window size on GUI startup for the first window
wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
	set_window_size_and_position(window)
end)

-- Intercept the creation of every new window
wezterm.on("new-window", function(window)
	set_window_size_and_position(window)
end)

config.mouse_bindings = {
	-- CMD-click will open the link under the mouse cursor
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "SUPER",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
}

return config
