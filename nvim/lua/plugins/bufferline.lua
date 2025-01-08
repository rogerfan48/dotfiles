return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  config = function()
    local bufferline = require("bufferline")
    bufferline.setup({
      -- use ":h bufferline-configuration" to see all options
      options = {
        mode = "tabs",
        max_name_length = 30,
        max_prefix_length = 20,
        tab_size = 18,
        style_preset = bufferline.style_preset.no_italic,
        offsets = {
          {
            filetype = "neo-tree",
            highlight = "FileExplorerHL", -- color set at config/colors.lua
            text = "File Explorer",
            text_align = "center",
            separator = true,
          }
        },
      },
    })
  end
}
