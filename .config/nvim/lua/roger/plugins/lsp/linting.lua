return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local keymaps = require("roger.core.keymaps")
		keymaps.linting()

		local lint = require("lint")
		lint.linters = {
			cppcheck = {
				name = "cppcheck",
				cmd = "cppcheck",
				args = {
					"--enable=all", -- 啟用所有檢查
					"--std=c++17", -- 指定 C++ 標準
					"--inconclusive", -- 啟用不確定檢查
					"--template=gcc", -- 輸出格式類似 GCC
					"--suppress=missingInclude", -- 忽略頭文件錯誤
					vim.fn.expand("%:p"), -- 當前文件的完整路徑
				},
				stdin = false,
				parser = require("lint.parser").from_errorformat([[ %f:%l:%c: %m ]], { source = "cppcheck" }),
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
			c = { "cppcheck" },
			cpp = { "cppcheck" },
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
