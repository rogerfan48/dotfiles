return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
    "b0o/schemastore.nvim", -- JSON Schema for jsonls
  },
  config = function()
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local capabilities = cmp_nvim_lsp.default_capabilities()

    local keymaps = require("roger.core.keymaps")
    keymaps.lsp()

    local lspcfg = vim.lsp.config

    lspcfg("*", {
      capabilities = capabilities,
    })

    lspcfg("clangd", {
      cmd = {
        "clangd",
        "--clang-tidy=false", -- 禁用 clang-tidy
        "--header-insertion=never", -- 可選，避免自動插入頭文件
      },
    })

    lspcfg("emmet_ls", {
      filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
    })

    lspcfg("lua_ls", {
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          completion = { callSnippet = "Replace" },
        },
      },
    })

    lspcfg("bashls", {
      filetypes = { "sh", "bash" },
    })

    lspcfg("marksman", {
      on_init = function(client)
        client.server_capabilities.semanticTokensProvider = nil
      end,
    })

    lspcfg("taplo", {
      settings = {
        taplo = {
          configuration = {
            evenBetterErrors = true,
            schema = { enabled = true },
          },
        },
      },
    })

    lspcfg("jsonls", {
      settings = {
        json = {
          schemas = require("schemastore").json.schemas(),
          validate = { enable = true },
        },
      },
    })

    vim.diagnostic.config({
      virtual_text = {
        spacing = 4,
        current_line = true,
        source = "if_many", -- 只在多來源時顯示來源
      },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "",
          [vim.diagnostic.severity.WARN] = "",
          [vim.diagnostic.severity.INFO] = "",
          [vim.diagnostic.severity.HINT] = "󰠠",
        },
      },
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })

    -- -- SEC: A temp solution to solve dartls error, which be solved by designating `cmd` in flutter-tools.nvim
    -- require("lspconfig").dartls.setup({
    --   on_new_config = function(cfg, _)
    --     local dart = vim.fn.exepath("dart")
    --     if dart ~= "" then
    --       cfg.cmd[1] = dart
    --     end -- 把 ./bin/dart 改掉
    --   end,
    -- })

    -- Don't show "Ambiguous link" from marksman
    vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      if client and client.name == "marksman" then
        local filtered = {}
        for _, diagnostic in ipairs(result.diagnostics or {}) do
          if not diagnostic.message:match("Ambiguous link") then
            table.insert(filtered, diagnostic)
          end
        end
        result.diagnostics = filtered
      end
      vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
    end
  end,
}
