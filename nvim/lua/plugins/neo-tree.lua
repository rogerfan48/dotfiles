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
    local keymaps = require("config.keymaps")
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
        },
      },
      window = {
        width = 36,
        mappings = {
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
      }
    })

    vim.cmd("silent Neotree reveal")
  end
}
