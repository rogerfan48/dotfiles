return {
  "github/copilot.vim",
  config = function()
    vim.g.copilot_filetypes = {
      ["*"] = true,
      -- ["javascript"] = true,
      -- ["typescript"] = true,
      -- ["python"] = true,
      -- ["lua"] = true,
    }
    vim.g.copilot_no_tab_map = true  -- Disable default tab mapping

    local keymaps = require("roger.core.keymaps")
    keymaps.copilot()
  end,
}
