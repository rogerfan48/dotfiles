return {
  "max397574/better-escape.nvim",
  config = function()
    require("better_escape").setup {
      timeout = 50,
      mappings = {
        i = { -- insert mode
          j = {
            k = function()
              vim.schedule(function()
                local line = vim.api.nvim_get_current_line()
                local trimmed_line = line:gsub("%s+$", "")
                vim.api.nvim_set_current_line(trimmed_line)
              end)
              return vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
            end
          },
          k = {
            j = function()
              vim.schedule(function()
                local line = vim.api.nvim_get_current_line()
                local trimmed_line = line:gsub("%s+$", "")
                vim.api.nvim_set_current_line(trimmed_line)
              end)
              return vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
            end
          },
        },
        v = { -- visual mode
          j = {
            k = "<Esc>",
          },
          k = {
            j = "<Esc>",
          },
        },
        c = { -- command mode
          j = {
            k = "<Esc>",
          },
          k = {
            j = "<Esc>",
          },
        },
        t = { -- terminal mode
          j = {
            k = "<C-\\><C-n>",
          },
          k = {
            j = "<C-\\><C-n>",
          },
        },
      },
    }
  end
}
