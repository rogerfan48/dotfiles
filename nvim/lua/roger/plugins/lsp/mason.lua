return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")

    mason.setup()
    mason_lspconfig.setup({
      ensure_installed = {
        "lua_ls",   -- lua
        "clangd",   -- c/cpp
        "html",     -- html
        "cssls",    -- css/scss
        "ts_ls",    -- js/ts
        "emmet_ls", -- aid: HTML, JSX
        "pyright",  -- python
        "marksman", -- markdown
        "texlab",   -- latex
        "ast_grep", -- dart
      },
      -- automatic_installed = true,
    })
  end,
}
