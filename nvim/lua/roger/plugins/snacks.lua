return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  config = function()
    local keymaps = require("roger.core.keymaps")
    keymaps.snacks_image()

    require("snacks").setup({
      image = {
        enabled = true,

        -- float: popup while the cursor is on the link (needs inline = false)
        doc = {
          enabled = true,
          inline = false,
          float = true,
          max_width = 80,
          max_height = 40,
        },

        -- Bare `a.png` in a note means `./assets/a.png`.
        img_dirs = { "assets" },
      },
    })

    -- upstream at_cursor misses the row check for single-line images
    local doc = require("snacks.image.doc")
    doc.at_cursor = function(cb)
      local cursor = vim.api.nvim_win_get_cursor(0)
      doc.find(vim.api.nvim_get_current_buf(), function(imgs)
        for _, img in ipairs(imgs) do
          local r = img.range
          if
            r
            and cursor[1] >= r[1]
            and cursor[1] <= r[3]
            and (r[1] ~= r[3] or (cursor[2] >= r[2] and cursor[2] <= r[4]))
          then
            return cb(img.src, img.pos)
          end
        end
        cb()
      end, { from = cursor[1], to = cursor[1] + 1 })
    end
  end,
}
