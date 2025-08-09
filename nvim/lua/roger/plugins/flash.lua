return {
  "folke/flash.nvim",
  event = "VeryLazy",
  keys = require("roger.core.keymaps").flash,
  config = function()
    require("flash").setup({
      modes = {
        search = {
          enabled = true,
        },
        char = {
          jump_labels = true,
        }
      },
    })

    vim.api.nvim_set_hl(0, "FlashLabel", { bg = "#FF0000", fg = "#ffffff", bold = true })
    vim.api.nvim_set_hl(0, "FlashMatch", { bg = "#89dceb", fg = "#000000" })
    vim.api.nvim_set_hl(0, "FlashCurrent", { bg = "#fab387", fg = "#000000" })
  end
}
