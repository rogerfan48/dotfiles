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
    local lspconfig = require("lspconfig")
    local mason_lspconfig = require("mason-lspconfig")

    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local capabilities = cmp_nvim_lsp.default_capabilities()

    local keymaps = require("roger.core.keymaps")
    keymaps.lsp()

    -- Change the Diagnostic symbols in the sign column (gutter)
    -- (not in youtube nvim video)
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    mason_lspconfig.setup_handlers({
      function(server_name)
        lspconfig[server_name].setup({
          capabilities = capabilities,
        })
      end,
      ["clangd"] = function()
        lspconfig.clangd.setup({
          capabilities = capabilities,
          cmd = {
            "clangd",
            "--clang-tidy=false", -- 禁用 clang-tidy
            "--header-insertion=never", -- 可選，避免自動插入頭文件
          },
        })
      end,
      ["emmet_ls"] = function()
        lspconfig["emmet_ls"].setup({
          capabilities = capabilities,
          filetypes = {
            "html",
            "typescriptreact",
            "javascriptreact",
            "css",
            "sass",
            "scss",
            "less",
            "svelte",
          },
        })
      end,
      ["lua_ls"] = function()
        lspconfig["lua_ls"].setup({
          capabilities = capabilities,
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        })
      end,
      ["bashls"] = function()
        lspconfig.bashls.setup({
          capabilities = capabilities,
          filetypes = { "sh", "bash" },
        })
      end,
      ["marksman"] = function()
        lspconfig.marksman.setup({
          capabilities = capabilities,
          on_init = function(client, _)
            client.server_capabilities.semanticTokensProvider = nil
          end,
        })
      end,
      ["taplo"] = function()
        require("lspconfig").taplo.setup({
          capabilities = capabilities,
          settings = {
            taplo = {
              configuration = {
                evenBetterErrors = true,
                schema = { enabled = true },
              },
            },
          },
        })
      end,
      ["jsonls"] = function()
        lspconfig.jsonls.setup({
          capabilities = capabilities,
          settings = {
            json = {
              schemas = require("schemastore").json.schemas(),
              validate = { enable = true },
            },
          },
          init_options = {
            provideFormatter = false, -- ∵ using prettier
          },
        })
      end,
    })

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
