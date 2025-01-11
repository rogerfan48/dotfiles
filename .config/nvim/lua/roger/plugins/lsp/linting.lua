return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local keymaps = require("roger.core.keymaps")
		keymaps.linting()

		local lint = require("lint")
		local lp = require("lint.parser")
		local function create_linter_config(config)
			return vim.tbl_extend("force", {
				stdin = false,
				stream = "both",
			}, config)
		end
		lint.debug = true
		lint.linters = {
			cppcheck = create_linter_config({
				name = "cppcheck",
				cmd = "cppcheck",
				args = {
					"--enable=all", -- 啟用所有檢查
					"--std=c++20", -- 指定 C++ 標準
					"--inconclusive", -- 啟用不確定檢查
					"--template=gcc", -- 輸出格式類似 GCC
					"--suppress=missingIncludeSystem", -- 忽略頭文件錯誤
					"--suppress=checkersReport",
					-- vim.fn.expand("%:p"), -- 當前文件的完整路徑
				},
				parser = lp.from_pattern(
          [[(%d+):(%d+): (%a+): (.+)]],
          { "lnum", "col", "severity", "message" },
          { -- because of --template=gcc, the severity type are mapped to only four instead of 6 from cppcheck
            ["fatal error"] = vim.diagnostic.severity.ERROR,
            ["error"]       = vim.diagnostic.severity.ERROR,
            ["warning"]     = vim.diagnostic.severity.WARN,
            ["note"]        = vim.diagnostic.severity.HINT,
          }, { source = "cppcheck" }, {}),
			}),
      markdownlint = create_linter_config({
        name = "markdownlint",
        cmd = "markdownlint",
        parser = lp.from_errorformat("%f:%l:%c: %m", { source = "markdownlint" }),
      }),
			yamllint = create_linter_config({
				name = "yamllint",
				cmd = "yamllint",
				args = { "--format=parsable" },
				parser = lp.from_errorformat("%f:%l:%c: %m", { source = "yamllint" }),
			}),
			dartanalyzer = create_linter_config({
				name = "dartanalyzer",
				cmd = "dart",
				args = { "analyze", "--format", "machine" },
				append_fname = false,
				parser = lp.from_errorformat("%f|%l|%c|%t|%m", { source = "dartanalyzer" }),
			}),
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
