return {
  "gbprod/substitute.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local keymaps = require("roger.core.keymaps")
    keymaps.substitute()

    local substitute = require("substitute")
    substitute.setup()
  end,
}
