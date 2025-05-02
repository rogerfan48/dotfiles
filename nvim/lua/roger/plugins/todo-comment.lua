return {
  "folke/todo-comments.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local keymaps = require("roger.core.keymaps")
    keymaps.todo_comments()

    local todo_comments = require("todo-comments")
    todo_comments.setup({
      signs = true, -- show icons in the signs column
      keywords = {
        -- FIX:
        -- WARN:
        -- HACK: Here are something strange
        -- TODO: Here are what need to be done
        -- INFO: Here are some information
        -- NOTE: Here are some notes
        -- SEC: Section information
        FIX =  { icon = " ", color = "error", alt = { "FIXME", "BUG", "!!!" } },
        WARN = { icon = " ", color = "warning", alt = {  } },
        HACK = { icon = " ", color = "warning" },
        TODO = { icon = "󰄱 ", color = "todo" },
        NOTE = { icon = " ", color = "note", alt = { "INFO", "HINT" } },
        SEC =  { icon = "󰚟 ", color = "sec", alt = {  } },
        -- PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        -- TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
      colors = {
        error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
        warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
        todo = { "#8fd9d5" },
        note = { "#9edbbc" },
        sec = { "#b2ccd1" },
        default = { "Identifier", "#7C3AED" },
        -- test = { "Identifier", "#FF00FF" }
      },
    })
  end
}
