return {
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPre", "BufNewFile" },
    main = "ibl",
    config = function()
      require("ibl").setup {
        indent = { char = "┊" },
        scope = {
          enabled = true,
          show_start = true,
          show_end = true
        },
        exclude = {
          filetypes = { "help", "terminal", "dashboard" },
          buftypes = { "nofile", "terminal" },
        },
      }
    end
  },
  {
    "echasnovski/mini.indentscope",
    version = "*",
    config = function()
      require("mini.indentscope").setup {
        symbol = "┊",
        draw = {
          delay = 10,
          animation = require("mini.indentscope").gen_animation.none(),
        },
        options = {
          try_as_border = true,
        },
      }
    end
  }
}
