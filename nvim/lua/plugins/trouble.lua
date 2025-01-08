return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" },
  opts = {
    focus = true,
  },
  cmd = "Trouble",
  keys = {
    { "<leader>xw", ":Trouble diagnostics toggle<cr>",              desc = "Open trouble workspace diagnostics" },
    { "<leader>xd", ":Trouble diagnostics toggle filter.buf=0<cr>", desc = "Open trouble document diagnostics" },
    { "<leader>xq", ":Trouble quickfix toggle<cr>",                 desc = "Open trouble quickfix list" },
    { "<leader>xl", ":Trouble loclist toggle<cr>",                  desc = "Open trouble location list" },
    { "<leader>xt", ":Trouble todo toggle<cr>",                     desc = "Open todos in trouble" },
  },
}
