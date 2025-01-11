return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local keymaps = require("roger.core.keymaps")
		keymaps.formatting()

		local conform = require("conform")
		conform.setup({
			formatters_by_ft = {
				lua = { "stylua" },
				c = { "clang_format" },
				cpp = { "clang_format" },
				html = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				python = { "isort", "black" },
				dart = { "ast_grep" },
				markdown = { "prettier" },
				latex = { "latexindent" },
				json = { "prettier" },
				yaml = { "prettier" },
			},
			-- format_on_save = {
			-- 	lsp_fallback = false,
			-- 	async = false,
			-- 	timeout_ms = 1000,
			-- },
		})
	end,
}
