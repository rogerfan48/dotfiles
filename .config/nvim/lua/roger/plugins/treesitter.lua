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
      ensure_installed = { "lua", "c", "cpp" },
      auto_install = true,
      sync_install = false,
      ignore_install = {},
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
      autotag = {
        enable = true,
      },
      incremental_selection = {
        enable = true,
        keymaps = keymaps.treesitter,
      },
    })
  end
}
