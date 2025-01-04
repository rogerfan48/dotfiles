return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "clangd", "ts_ls" },
        -- automatic_installed = true,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- ::Manually Setting::
      -- local lspconfig = require("lspconfig")
      -- lspconfig.lua_ls.setup({})
      -- lspconfig.ts_ls.setup({})

      -- ::Automatically Setting::
      local lspconfig = require("lspconfig")
      local mason_lspconfig = require("mason-lspconfig")
      local keymaps = require("config.keymaps")

---@diagnostic disable-next-line: unused-local
      local on_attach = function(client, bufnr)
        -- 假設對 tsserver 禁用格式化
        -- if client.name == "tsserver" then
        --   client.server_capabilities.documentFormattingProvider = false
        -- end
        keymaps.lsp(bufnr)
      end

      mason_lspconfig.setup_handlers({
        function(server_name)
          lspconfig[server_name].setup({
            on_attach = on_attach,
          })
        end,
        -- ::Specific LSP Setting::
        ["lua_ls"] = function()
          lspconfig.lua_ls.setup({
            on_attach = on_attach,
            settings = {
              Lua = {
                diagnostics = { globals = { "vim", "bufnr" } },
              },
            },
          })
        end,
      })
    end
  }
}
