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
      source_selector = {
        winbar = true, -- toggle to show selector on winbar
        statusline = false, -- toggle to show selector on statusline
        show_scrolled_off_parent_node = false, -- boolean
        sources = { -- table
          {
            source = "filesystem", -- string
            display_name = " 󰉓 File ", -- string | nil
          },
          {
            source = "git_status", -- string
            display_name = " 󰊢 Git ", -- string | nil
          },
          {
            source = "buffers", -- string
            display_name = " 󰈚 Buffer ", -- string | nil
          },
        },
        content_layout = "center", -- string
        tabs_layout = "equal", -- string
        truncation_character = "…", -- string
        tabs_min_width = nil, -- int | nil
        tabs_max_width = nil, -- int | nil
        padding = 0, -- int | { left: int, right: int }
        separator = { left = "", right = "" }, -- string | { left: string, right: string, override: string | nil }
        separator_active = nil, -- string | { left: string, right: string, override: string | nil } | nil
        show_separator_on_edge = nil, -- boolean
        highlight_tab = "NeoTreeTabInactive", -- string
        highlight_tab_active = "NeoTreeTabActive", -- string
        highlight_background = "NeoTreeTabInactive", -- string
        highlight_separator = "NeoTreeTabSeparatorInactive", -- string
        highlight_separator_active = "NeoTreeTabSeparatorActive", -- string
      },
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
          hide_by_pattern = {},
          always_show = {},
          always_show_by_pattern = {},
          never_show = {
            ".DS_Store",
            ".Trash",
          },
          never_show_by_pattern = {},
        },
      },
      window = {
        width = 42,
        mappings = {
          ["h"] = "close_node",
          ["Z"] = "close_all_nodes",
          ["z"] = "expand_all_nodes",
          -- ["b"] = "rename_basename",
          ["<cr>"] = {
            function(state)
              open_and_maybe_close(state, true)
            end,
            desc = "Open and close Neotree",
          },
          ["<tab>"] = {
            function(state)
              open_and_maybe_close(state, false)
            end,
            desc = "Open but keep Neotree open",
          },
          ["t"] = {
            function(state)
              local node = state.tree:get_node()
              if node and node.path then
                vim.cmd("tabedit " .. vim.fn.fnameescape(node.path))
              end
            end,
            desc = "Open in new tab",
          },
          ["y"] = {
            function(state)
              vim.fn.setreg("+", state.tree:get_node().path)
            end,
            desc = "copy path to clipboard",
          },
          ["A"] = "git_add_all",
          ["gu"] = "git_unstage_file",
          ["ga"] = "git_add_file",
          ["gr"] = "git_revert_file",
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
      default_component_configs = {
        git_status = {
          symbols = {
            -- Change type
            added = "", -- "",
            deleted = "", -- "",
            modified = "", -- "",
            renamed = "", -- "",
            -- Status type
            untracked = "󰄗",
            ignored = "",
            unstaged = "󰄱",
            staged = "󰄵",
            conflict = "",
          },
        },
      },
    })

    vim.api.nvim_set_hl(0, "FileExplorerHL", { fg = "#dddddd", bg = "#313457", bold = true })
    vim.api.nvim_set_hl(0, "NeoTreeTabActive", { fg = "#dddddd", bg = "#487385", bold = true })
    vim.api.nvim_set_hl(0, "NeoTreeTabInactive", { bg = "#32435e" })

    -- NeoTreeGitAdded
    -- NeoTreeGitConflict
    -- NeoTreeGitDeleted
    -- NeoTreeGitIgnored
    -- NeoTreeGitModified
    -- NeoTreeGitUntracked

    vim.cmd("silent Neotree reveal")
  end,
}
