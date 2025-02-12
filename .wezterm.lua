-- Pull in the wezterm API
local wezterm = require("wezterm")
local home = os.getenv("HOME")

-- This will hold the configuration.
local config = wezterm.config_builder()

config.term = "wezterm"

config.initial_rows = 50
config.initial_cols = 200
config.max_fps = 120

config.font = wezterm.font_with_fallback({
  { family = "JetBrainsMono Nerd Font Mono", weight = "Medium" },
  { family = "jf-openhuninn-2.0" },
  { family = "LXGW WenKai Mono TC", weight = "Bold" },
})
config.font_size = 13
config.harfbuzz_features = { "calt=0" } -- disable ligatures

config.enable_tab_bar = false
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"

config.background = {
  {
    source = { File = home .. "/.dotfiles/bg_image/Sonoma.jpeg" },
    width = "Cover",
    height = "Cover",
  },
  {
    source = { Color = "#1e1e2e" },
    width = "100%",
    height = "100%",
    opacity = 0.93,
  },
}

local ansi_colors = {
  "#45475a", -- black
  "#f38ba8", -- red
  "#a6e3a1", -- green
  "#f9e2af", -- yellow
  "#6ec7ff", -- blue
  "#ffa3e7", -- magenta
  "#94e2d5", -- cyan
  "#bac2de", -- white
}
local bright_colors = {
  "#585b70", -- black
  "#f38ba8", -- red
  "#a6e3a1", -- green
  "#f9e2af", -- yellow
  "#6ec7ff", -- blue
  "#ffa3e7", -- magenta
  "#94e2d5", -- cyan
  "#a6adc8", -- white
}

config.colors = {
  foreground = "#cdd6f4",
  background = "#1e1e2e",
  compose_cursor = "#f2cdcd",
  cursor_bg = "#f5e0dc",
  cursor_border = "#f5e0dc",
  cursor_fg = "#11111b",
  selection_bg = "#585b70",
  selection_fg = "#cdd6f4",
  scrollbar_thumb = "#585b70",
  split = "#6c7086",
  visual_bell = "#313244",
  ansi = ansi_colors,
  brights = bright_colors,
}

config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
local window_frame_size = "10px"
local window_frame_color = "#2e4063"
config.window_frame = {
  border_left_width = window_frame_size,
  border_right_width = window_frame_size,
  border_bottom_height = window_frame_size,
  border_top_height = window_frame_size,
  border_left_color = window_frame_color,
  border_right_color = window_frame_color,
  border_bottom_color = window_frame_color,
  border_top_color = window_frame_color,
}

return config
