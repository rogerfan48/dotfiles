---@diagnostic disable: missing-fields
return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    local keymaps = require("roger.core.keymaps")
    local configs = require("nvim-treesitter.configs")
    configs.setup({
      ensure_installed = { "lua", "c", "cpp", "latex" },
      auto_install = true,
      sync_install = false,
      ignore_install = {},
      highlight = { enable = true, additional_vim_regex_highlighting = { "latex" } },
      indent = { enable = true, disable = { "python", "latex" } },
      fold = { enable = true },
      autotag = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = keymaps.treesitter,
      },
    })
  end,
}
