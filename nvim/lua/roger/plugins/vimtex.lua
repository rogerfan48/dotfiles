return {
  "lervag/vimtex",
  lazy = false,
  init = function()
    vim.g.vimtex_view_method = "skim"

    -- Make Skim open in the background and not steal focus
    vim.g.vimtex_view_skim_sync = 1
    vim.g.vimtex_view_skim_activate = 0

    -- Set the engine to xelatex for better Chinese support
    -- latexmk is the default compiler for vimtex, which is powerful
    vim.g.vimtex_compiler_latexmk = {
      engine = "xelatex",
    }

    -- Disable the log file generation to avoid cluttering the directory
    vim.g.vimtex_log_enabled = 0
  end,
}
