return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    local keymaps = require("config.keymaps")
    local configs = require("nvim-treesitter.configs")
    configs.setup({
      auto_install = true,
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
