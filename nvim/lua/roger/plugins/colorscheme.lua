return {
  "catppuccin/nvim",
  lazy = false,
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      transparent_background = true,
      custom_highlights = function(colors)
        return {
          Changed = { fg = colors.yellow },
          GitSignsChange = { fg = colors.yellow },
          NeoTreeGitUnstaged = { fg = colors.red },
          NeoTreeGitUntracked = { fg = colors.mauve },
        }
      end,
    })
    vim.cmd("colorscheme catppuccin")
  end
}
