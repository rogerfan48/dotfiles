local keymaps = require("roger.core.keymaps")

return {
  "SCJangra/table-nvim",
  ft = "markdown",
  opts = {
    padd_column_separators = true, -- Insert a space around column separators.
    mappings = keymaps.table
  },
}
