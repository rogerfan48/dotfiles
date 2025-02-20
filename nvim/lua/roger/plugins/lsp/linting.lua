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
    local function combined_parser(output, bufnr, linter_cwd)
      local diagnostics = {}

      -- 定義包含 col 的解析器
      local parser_with_col = lp.from_pattern(
        "(.+):(%d+):(%d+) (.+)",
        { "file", "lnum", "col", "message" },
        {},
        { source = "markdownlint", severity = vim.diagnostic.severity.WARN }
      )

      -- 定義不包含 col 的解析器
      local parser_without_col = lp.from_pattern(
        "(.+):(%d+) (.+)",
        { "file", "lnum", "message" },
        {},
        { source = "markdownlint", severity = vim.diagnostic.severity.WARN }
      )

      -- 逐行嘗試解析
      for line in output:gmatch("[^\n]+") do
        local diags = parser_with_col(line, bufnr, linter_cwd)
        if not diags or #diags == 0 then
          diags = parser_without_col(line, bufnr, linter_cwd)
        end
        if diags and #diags > 0 then
          for _, d in ipairs(diags) do
            table.insert(diagnostics, d)
          end
        end
      end

      return diagnostics
    end
    lint.debug = true
    lint.linters = {
      cppcheck = create_linter_config({
        name = "cppcheck",
        cmd = "cppcheck",
        args = function()
          local args = {
            "--enable=all", -- 啟用所有檢查
            "--std=c++20", -- 指定 C++ 標準
            "--inconclusive", -- 啟用不確定檢查
            "--template=gcc", -- 輸出格式類似 GCC
            "--suppress=missingIncludeSystem", -- 忽略頭文件錯誤
            "--suppress=checkersReport",
            -- vim.fn.expand("%:p"), -- 當前文件的完整路徑
          }

          -- check if "build/compile_commands.json" exists or not
          local compile_commands_path = vim.fn.findfile("build/compile_commands.json", ".;")
          if compile_commands_path and compile_commands_path ~= "" then
            table.insert(args, "--project=" .. compile_commands_path)
          end

          return args
        end,
        parser = lp.from_pattern(
          [[(%d+):(%d+): (%a+): (.+)]],
          { "lnum", "col", "severity", "message" },
          { -- because of --template=gcc, the severity type are mapped to only four instead of 6 from cppcheck
            ["fatal error"] = vim.diagnostic.severity.ERROR,
            ["error"] = vim.diagnostic.severity.ERROR,
            ["warning"] = vim.diagnostic.severity.WARN,
            ["note"] = vim.diagnostic.severity.HINT,
          },
          { source = "cppcheck" },
          {}
        ),
      }),
      pylint = create_linter_config({
        name = "pylint",
        cmd = "pylint",
        ignore_exitcode = true,
        parser = lp.from_errorformat("%f:%l:%c: %m", { source = "pylint" })
      }),
      markdownlint = create_linter_config({
        name = "markdownlint",
        cmd = "markdownlint",
        args = { "--config", "~/.dotfiles/.markdownlint.jsonc" },
        ignore_exitcode = true,
        parser = combined_parser,
      }),
      jsonlint = create_linter_config({
        name = "jsonlint",
        cmd = "jsonlint",
        args = { "--compact" },
        ignore_exitcode = true,
        parser = lp.from_pattern(
          [[line (%d+), col (%d+), (.+)]],
          { "lnum", "col", "message" },
          {},
          { source = "jsonlint", severity = vim.diagnostic.severity.WARN }
        ),
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
      shellcheck = create_linter_config({
        name = "shellcheck",
        cmd = "shellcheck",
        args = { "--format=gcc", "--color=never" },
        stream = "stdout", -- using "both" will appear twice
        ignore_exitcode = true, -- shellcheck: "0": no problem occurred, "1": one or more problem(s) occurred, "2": command failed
        parser = lp.from_pattern([[(%d+):(%d+): (%a+): (.+)]], { "lnum", "col", "severity", "message" }, {
          ["fatal error"] = vim.diagnostic.severity.ERROR,
          ["error"] = vim.diagnostic.severity.ERROR,
          ["warning"] = vim.diagnostic.severity.WARN,
          ["note"] = vim.diagnostic.severity.HINT,
        }, { source = "shellcheck" }, {}),
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
      jsonc = { "jsonlint" },
      yaml = { "yamllint" },
      sh = { "shellcheck" },
      bash = { "shellcheck" },
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

    vim.api.nvim_create_user_command("LintInfo", function()
      local filetype = vim.bo.filetype
      local linters = require("lint").linters_by_ft[filetype]

      if linters then
        print("Linters for " .. filetype .. ": " .. table.concat(linters, ", "))
      else
        print("No linters configured for filetype: " .. filetype)
      end
    end, {})
  end,
}
