return {
  "mason-org/mason.nvim",
  dependencies = {
    "mason-org/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local mason_tool_installer = require("mason-tool-installer")

    mason.setup()
    mason_lspconfig.setup({
      ensure_installed = {
        "lua_ls", -- lua
        "clangd", -- c/cpp
        "html", -- html
        "cssls", -- css/scss
        "ts_ls", -- js/ts
        -- "emmet_ls", -- aid: HTML, JSX
        "pyright", -- python
        "marksman", -- markdown
        "jsonls", -- JSON
        "texlab", -- latex
        "bashls", -- bash
        "taplo", -- TOML
      },
      automatic_enable = true, -- default setting
      -- automatic_enable = { "lua_ls", "vimls" }, -- only enable certain servers to be auto enabled
      -- automatic_enable = { -- exclude certain servers from being auto enabled
      --   exclude = { "eslint" },
      -- },
    })

    mason_tool_installer.setup({
      ensure_installed = {
        -- Formatters
        "stylua", -- Lua
        "clang-format", -- C/C++
        "prettier", -- HTML, CSS, SCSS, JS/TS
        "isort", -- Python
        "black", -- Python
        "latexindent", -- LaTeX
        "shfmt", -- Bash

        -- Linters
        -- "cppcheck", -- C/C++
        "eslint_d", -- JavaScript/TypeScript, React.js
        "pylint", -- Python
        -- "dartanalyzer", -- Dart
        "markdownlint", -- Markdown
        "jsonlint",
        "yamllint",
        "shellcheck", -- Bash
      },
    })
  end,
}
