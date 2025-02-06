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
	pattern = { "c", "cpp", "python", "sh", "bash", "markdown" },
	callback = function()
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
	end,
})

-- Spelling check
vim.o.spell = true
vim.o.spelllang = "en,cjk"
vim.o.spelloptions = "camel" -- recognizing camelCase naming

-- Ensure 10 lines are visible above and below the cursor
vim.o.scrolloff = 10

-- search settings
vim.o.ignorecase = true -- ignore case when searching
vim.o.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- turn on termguicolors for colorscheme to work
-- (have to use iterm2 or any other true color terminal)
vim.o.termguicolors = true
vim.o.background = "dark" -- colorschemes that can be light or dark will be made dark
vim.o.signcolumn = "yes" -- show sign column so that text doesn't shift

-- Permanent undofile history
vim.o.undofile = true
-- if directory not exist, create one.
local undodir = vim.fn.stdpath("data") .. "/undo"
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p")
end
vim.o.undodir = undodir

vim.o.backspace = "indent,eol,start" -- enable backspace to delete ...
vim.o.splitright = true -- split vertical window to the right
vim.o.splitbelow = true -- split horizontal window to the bottom
vim.o.swapfile = false
vim.o.showmode = false -- whether to show mode in command line (close when use lualine)

vim.opt.fillchars.eob = " " -- End of Buffer, default: "~"

-- wrap
vim.o.wrap = true
vim.o.linebreak = true -- will not split a word
vim.o.breakindent = true -- enable indentation for wrapped text
-- vim.o.breakindentopt = "shift:2" -- 設定換行後的縮排大小 (2 spaces)
vim.o.showbreak = "  " -- the beginning of the wrapped text

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function ()
    vim.highlight.on_yank()
  end,
})

-- vim.o.conceallevel = 2
-- For obsidian.nvim
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.conceallevel = 2
  end,
})

vim.diagnostic.config({
  float = {
    border = "rounded", -- Add border to "]d", "[d" panel
  }
})
