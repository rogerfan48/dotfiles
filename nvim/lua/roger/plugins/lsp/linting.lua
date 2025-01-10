return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local keymaps = require("roger.core.keymaps")
		keymaps.linting()

		local lint = require("lint")
		lint.linters = {
			clangtidy = {
				name = "clangtidy",
				cmd = "clang-tidy",
				args = { "--quiet" },
				stdin = false,
				append_fname = true,
				ignore_exitcode = true,
				parser = require("lint.parser").from_errorformat([[%f:%l:%c: %tarning: %m;%f:%l:%c: %trror: %m]], {}),
			},
			dartanalyzer = {
				name = "dartanalyzer",
				cmd = "dart",
				args = { "analyze", "--format", "machine" },
				stdin = false,
				append_fname = false,
				ignore_exitcode = true,
				parser = require("lint.parser").from_errorformat([[%f|%l|%c|%t|%m]], {}),
			},
		}
		lint.linters_by_ft = {
			-- lua = {},
			c = { "clangtidy" },
			cpp = { "clangtidy" },
			-- html = {},
			-- css = {},
			-- scss = {},
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			python = { "pylint" },
			dart = { "dartanalyzer" },
			markdown = { "markdownlint" },
			-- latex = { "chktex" },
			json = { "jsonlint" },
			yaml = { "yamllint" },
		}

		-- lint.linters = {
		-- 	clangtidy = {
		-- 		cmd = "clang-tidy",
		-- 		args = { "--quiet", "%filepath" },
		-- 		stdin = false,
		-- 		append_fname = false, -- 防止自動附加文件名
		-- 		ignore_exitcode = true, -- 不強制要求 0 作為退出碼
		-- 		parser = require("lint.parser").from_errorformat("%f:%l:%c: %tarning: %m", "%f:%l:%c: %trror: %m"),
		-- 	},
		-- }

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})
	end,
}
