return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local custom_dracula = require('lualine.themes.dracula')
    custom_dracula.insert.a.bg = '#7bc864'

    require('lualine').setup({
      options = {
        theme = custom_dracula
      }
    })
  end
}
