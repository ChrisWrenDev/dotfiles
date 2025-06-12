-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

config.color_scheme = 'TokyoNight'

config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 18

config.hide_tab_bar_if_only_one_tab = true

-- How many lines of scrollback you want to retain per tab
config.scrollback_lines = 3500
config.enable_scroll_bar = true

config.window_decorations = "RESIZE"

-- config.window_background_opacity = 0.8
-- config.macos_window_background_blur = 10

-- and finally, return the configuration to wezterm
return config
