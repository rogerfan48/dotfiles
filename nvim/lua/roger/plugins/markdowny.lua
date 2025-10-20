return {
  "antonk52/markdowny.nvim",
  config = function()
    local keymaps = require("roger.core.keymaps")
    keymaps.markdowny()

    require("markdowny").setup({ filetypes = { "markdown", "txt" } })
  end,
}
