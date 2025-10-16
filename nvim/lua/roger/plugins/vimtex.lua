return {
  "lervag/vimtex",
  lazy = false,
  init = function()
    vim.g.vimtex_view_method = "skim"
    -- Make Skim open in the background and not steal focus
    vim.g.vimtex_view_skim_sync = 1
    vim.g.vimtex_view_skim_activate = 0
  end,
  config = function()
    local keymaps = require("roger.core.keymaps")
    keymaps.vimtex()

    vim.api.nvim_create_autocmd("User", {
      pattern = { "VimtexEventQuit", "VimtexEventCompileStopped" },
      callback = function(ev)
        vim.api.nvim_buf_call(ev.buf, function()
          vim.cmd("VimtexClean")
        end)
      end,
    })
  end,
}
