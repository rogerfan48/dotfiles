return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
		"3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
	},
	lazy = false,
	config = function()
		local keymaps = require("roger.core.keymaps")
		keymaps.neo_tree()

		local function open_and_maybe_close(state, close)
			local node = state.tree:get_node()
			if node.type == "directory" then
				state.commands["toggle_node"](state)
			else
				require("neo-tree.sources.filesystem.commands").open(state)
				if close then
					require("neo-tree.command").execute({ action = "close" })
				end
			end
		end

		require("neo-tree").setup({
			close_if_last_window = true,
			filesystem = {
				follow_current_file = {
					enabled = true,
					leave_dirs_open = true,
				},
				filtered_items = {
					hide_dotfiles = false,
					hide_gitignored = false,
					hide_by_name = {},
					never_show = {
						".DS_Store",
						".Trash",
					},
				},
			},
			window = {
				width = 40,
				mappings = {
					["C"] = "close_node",
					["Z"] = "close_all_nodes",
					["z"] = "expand_all_nodes",
					-- ["b"] = "rename_basename",
					["<cr>"] = function(state)
						open_and_maybe_close(state, false)
					end,
					["<tab>"] = function(state)
						open_and_maybe_close(state, false)
					end,
				},
			},
			buffer = {
				follow_current_file = {
					enabled = true,
					leave_dirs_open = true,
				},
			},
			event_handlers = {
				{
					event = "neo_tree_buffer_enter",
					handler = function(_)
						vim.cmd("setlocal relativenumber")
					end,
				},
			},
		})

		vim.cmd("silent Neotree reveal")
	end,
}
