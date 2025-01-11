vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.o.relativenumber = true
vim.o.number = true
vim.o.cursorline = true

vim.o.expandtab = true
vim.o.smartindent = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "c", "cpp", "python" },
	callback = function()
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
	end,
})

-- search settings
vim.o.ignorecase = true -- ignore case when searching
vim.o.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- turn on termguicolors for colorscheme to work
-- (have to use iterm2 or any other true color terminal)
vim.o.termguicolors = true
vim.o.background = "dark" -- colorschemes that can be light or dark will be made dark
vim.o.signcolumn = "yes" -- show sign column so that text doesn't shift

vim.o.backspace = "indent,eol,start"

vim.o.splitright = true -- split vertical window to the right
vim.o.splitbelow = true -- split horizontal window to the bottom

vim.o.swapfile = false
vim.o.showmode = false

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function ()
    vim.highlight.on_yank()
  end,
})
