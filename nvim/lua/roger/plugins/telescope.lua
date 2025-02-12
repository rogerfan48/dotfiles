return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
      "folke/todo-comments.nvim",
      "folke/trouble.nvim",
    },
    config = function()
      local keymaps = require("roger.core.keymaps")
      keymaps.telescope()

      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local transform_mod = require("telescope.actions.mt").transform_mod

      local trouble = require("trouble")
      local trouble_telescope = require("trouble.sources.telescope")

      -- or create your custom action
      local custom_actions = transform_mod({
        open_trouble_qflist = function(prompt_bufnr)
          trouble.toggle("quickfix")
        end,
      })

      local state = require("telescope.state")
      local action_state = require("telescope.actions.state")

      local slow_scroll = function(prompt_bufnr, direction)
        local previewer = action_state.get_current_picker(prompt_bufnr).previewer
        local status = state.get_status(prompt_bufnr)

        -- Check if we actually have a previewer and a preview window
        if type(previewer) ~= "table" or previewer.scroll_fn == nil or status.preview_win == nil then
          return
        end

        previewer:scroll_fn(1 * direction)
      end

      telescope.setup({
        defaults = {
          layout_strategy = "vertical",
          layout_config = {
            vertical = {
              preview_height = 0.65,
            },
            height = 0.95,
          },
          file_ignore_patterns = {
            "^.git/", -- don't show .git/ in all Telescope utilities
            "^node_modules/",
          },
          path_display = { "smart" },
          mappings = {
            i = {
              ["<C-k>"] = actions.move_selection_previous, -- move to prev result
              ["<C-j>"] = actions.move_selection_next, -- move to next result
              ["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
              ["<C-t>"] = trouble_telescope.open,
              ["<C-e>"] = function(bufnr)
                slow_scroll(bufnr, 1)
              end,
              ["<C-y>"] = function(bufnr)
                slow_scroll(bufnr, -1)
              end,
              ["<Esc>"] = actions.close,
            },
          },
        },
        pickers = {
          live_grep = {
            additional_args = function(_)
              return { "--hidden" }
            end
          },
          find_files = {
            hidden = true,
          }
        },
        extensions = {
          fzf = {
            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = "smart_case", -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
          },
        },
      })

      telescope.load_extension("fzf")
    end,
  },
  {
    -- used for code action, initially
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
      })
      require("telescope").load_extension("ui-select")
    end,
  },
}
