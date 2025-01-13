return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
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
				"emmet_ls", -- aid: HTML, JSX
				"pyright", -- python
				"marksman", -- markdown
				"texlab", -- latex
				"ast_grep", -- dart
        "bashls", -- bash
			},
			-- automatic_installed = true,
		})

		mason_tool_installer.setup({
			ensure_installed = {
				-- Formatters
				"stylua", -- Lua
				"clang-format", -- C/C++
				"prettier", -- HTML, CSS, SCSS, JS/TS
				"isort", -- Python
				"black", -- Python
				"ast_grep", -- Dart
				"latexindent", -- LaTeX
        "shfmt", -- Bash

				-- Linters
				-- "cppcheck", -- C/C++
				"eslint_d", -- JavaScript/TypeScript, React.js
				"pylint", -- Python
				-- "dartanalyzer", -- Dart
				"markdownlint", -- Markdown
				-- "chktex", -- LaTeX
				"jsonlint",
				"yamllint",
        "shellcheck", -- Bash
			},
		})
	end,
}
