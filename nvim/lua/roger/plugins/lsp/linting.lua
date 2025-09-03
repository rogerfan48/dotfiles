return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local keymaps = require("roger.core.keymaps")
    keymaps.linting()

    local lint = require("lint")
    
    lint.debug = true

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
      dart = {},
      markdown = { "markdownlint" },
      latex = { "chktex" },
      tex = { "chktex" },
      json = { "jsonlint" },
      jsonc = {},
      yaml = { "yamllint" },
      sh = { "shellcheck" },
      bash = { "shellcheck" },
    }

    local function register_linters(spec)
      for name, cfg in pairs(spec) do
        -- Trigger lazy load first to get the native definition (if any)
        local base = lint.linters[name] or {}
        -- Deep merge into the "same key", instead of replacing the whole table
        lint.linters[name] = vim.tbl_deep_extend("force", base, cfg)
      end
    end

    -- get current settings: `:lua print(vim.inspect(require('lint').linters.chktex))`
    register_linters({
      markdownlint = {
        args = { "--stdin", "--config", "~/.dotfiles/.markdownlint.jsonc" },
      },
      chktex = {
        ignore_exitcode = true,
      }
    })

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        if _G.IS_LEETCODE_SESSION then
          return
        end

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
