-- Pull in the wezterm API
local wezterm = require("wezterm")

local mux = wezterm.mux

-- maximise on starup
wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

-- This will hold the configuration
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 19

-- config.enable_tab_bar = false

config.window_decorations = "RESIZE"

-- config.window_background_opacity = 0.8
-- config.macos_window_background_blur = 10

-- Github Dark Default colorscheme:
config.colors = {
	foreground = "#d3d3d3",
	background = "#0d1117",
	cursor_bg = "#58a6ff",
	cursor_border = "#58a6ff",
	cursor_fg = "#0d1117",
	selection_bg = "#24416b",
	selection_fg = "#d3d3d3",
	ansi = {
		"#0d1117", -- Black (Usually same as background)
		"#ff7b72", -- Red
		"#3fb950", -- Green
		"#d29922", -- Yellow
		"#58a6ff", -- Blue
		"#bc8cff", -- Magenta
		"#39c5cf", -- Cyan
		"#b1bac4", -- White (Bright foreground)
	},
	brights = {
		"#6e7681", -- Bright Black (Dark grey)
		"#ffa198", -- Bright Red
		"#56d364", -- Bright Green
		"#e3b341", -- Bright Yellow
		"#79c0ff", -- Bright Blue
		"#d2a8ff", -- Bright Magenta
		"#56c2d6", -- Bright Cyan
		"#f0f6fc", -- Bright White (Brightest foreground)
	},
}

-- and finally, return the configuration to wezterm
return config
