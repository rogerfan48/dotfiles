return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
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
		})
	end,
	-- "neovim/nvim-lspconfig",
	-- config = function()
	--   local lspconfig = require("lspconfig")
	--   local mason_lspconfig = require("mason-lspconfig")
	--
	--   local capabilities = require("cmp_nvim_lsp").default_capabilities()
	--   local keymaps = require("roger.core.keymaps")
	--   local on_attach = function(client, bufnr)
	--     -- 假設對 tsserver 禁用格式化
	--     -- if client.name == "tsserver" then
	--     --   client.server_capabilities.documentFormattingProvider = false
	--     -- end
	--     keymaps.lsp(bufnr)
	--   end
	--
	--   mason_lspconfig.setup_handlers({
	--     function(server_name)
	--       lspconfig[server_name].setup({
	--         on_attach = on_attach,
	--         capabilities = capabilities,
	--       })
	--     end,
	--     -- ::Specific LSP Setting::
	--     ["lua_ls"] = function()
	--       lspconfig.lua_ls.setup({
	--         on_attach = on_attach,
	--         settings = {
	--           Lua = {
	--             diagnostics = { globals = { "vim", "bufnr" } },
	--           },
	--         },
	--       })
	--     end,
	--   })
	-- end,
}
