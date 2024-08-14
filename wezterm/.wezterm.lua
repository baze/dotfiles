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

return config
