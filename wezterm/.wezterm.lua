-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

config.color_scheme = "Catppuccin Frappe"

-- config.font = wezterm.font("MesloLGL Nerd Font Mono")
config.font = wezterm.font("JetBrainsMono Nerd Font Mono")
config.font_size = 14
config.line_height = 1.2

config.enable_tab_bar = false

config.window_decorations = "TITLE | RESIZE"

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

wezterm.on("gui-startup", function(cmd)
	local screen = wezterm.gui.screens().main
	local ratio = 0.6
	local width, height = screen.width * ratio, screen.height * ratio
	local tab, pane, window = wezterm.mux.spawn_window(cmd or {
		position = { x = (screen.width - width) / 2, y = (screen.height - height) / 2 },
	})
	-- window:gui_window():maximize()
	window:gui_window():set_inner_size(width, height)
end)

return config
