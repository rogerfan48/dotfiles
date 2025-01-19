-- Vim number and Vim relativenumber
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#7adff0", bold = true })
    vim.api.nvim_set_hl(0, "LineNr", { fg = "#4d5c6e" })
    vim.api.nvim_set_hl(0, "CursorLine", { bg = "#303040" })
  end
})
