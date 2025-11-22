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
        python = { "isort", "black_global" },
        dart = { "dart_format" },
        markdown = { "markdownlint-cli2" },
        latex = { "latexindent" },
        json = { "prettier" },
        yaml = { "prettier" },
        sh = { "shfmt" },
        bash = { "shfmt" },
      },
      formatters = {
        dart_format = {
          command = "dart",
          args = { "format", "$FILENAME", "--line-length", "100" },
          stdin = false,
          tempfile = "file",
        },
        black_global = {
          command = "black",
          args = {
            "--config",
            vim.fn.expand("~/.config/black/pyproject.toml"),
            "-",
          },
          stdin = true,
        },
      },
      -- format_on_save = {
      -- 	lsp_fallback = false,
      -- 	async = false,
      -- 	timeout_ms = 1000,
      -- },
    })
  end,
}
