return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  enabled = not _G.IS_LEETCODE_SESSION,
  config = function()
    local bufferline = require("bufferline")
    bufferline.setup({
      -- use ":h bufferline-configuration" to see all options
      options = {
        mode = "tabs",
        name_formatter = function(tab)
          -- 1. 找出 tab 內第一個「不是 neo-tree」的 buffer
          for _, bufnr in ipairs(tab.buffers) do
            if vim.bo[bufnr].filetype ~= "neo-tree" then
              -- 用檔名 (t) 或完整路徑 (.) 都可
              return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
            end
          end
          -- 2. 如果整個 tab 都只有 neo-tree，就回傳固定字串
          return "File Explorer"
        end,
        max_name_length = 30,
        max_prefix_length = 20,
        tab_size = 18,
        style_preset = bufferline.style_preset.no_italic,
        show_close_icon = false,
        offsets = {
          {
            filetype = "neo-tree",
            highlight = "FileExplorerHL", -- color set at config/colors.lua
            text = "File Explorer",
            text_align = "center",
            separator = true,
          },
        },
      },
    })
  end,
}
