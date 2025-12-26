return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local colors = {
      rosewater = "#f5e0dc",
      flamingo = "#f2cdcd",
      pink = "#f5c2e7",
      mauve = "#cba6f7",
      red = "#f38ba8",
      maroon = "#eba0ac",
      peach = "#fab387",
      yellow = "#f9e2af",
      green = "#a6e3a1",
      teal = "#94e2d5",
      sky = "#89dceb",
      sapphire = "#74c7ec",
      blue = "#89b4fa",
      lavender = "#b4befe",
      text = "#cdd6f4",
      subtext1 = "#bac2de",
      subtext0 = "#a6adc8",
      overlay2 = "#9399b2",
      overlay1 = "#7f849c",
      overlay0 = "#6c7086",
      surface2 = "#585b70",
      surface1 = "#45475a",
      surface0 = "#313244",
      base = "#1e1e2e",
      mantle = "#181825",
      crust = "#11111b",
    }

    local custom_theme = require("catppuccin.utils.lualine")("mocha")
    custom_theme.normal.c.fg = colors.overlay0
    custom_theme.visual.a.bg = colors.yellow

    custom_theme.normal.b.fg = colors.text
    custom_theme.insert.b.fg = colors.text
    custom_theme.visual.b.fg = colors.text
    custom_theme.replace.b.fg = colors.text

    local custom_filename = {
      "filename",
      file_status = true, -- Displays file status (readonly status, modified status)
      newfile_status = false, -- Display new file status (new file means no write after created)
      path = 3,
      -- 0: Just the filename
      -- 1: Relative path
      -- 2: Absolute path
      -- 3: Absolute path, with tilde as the home directory
      -- 4: Filename and parent dir, with tilde as the home directory

      shorting_target = 24, -- Shortens path to leave 40 spaces in the window
      -- for other components. (terrible name, any suggestions?)
      symbols = {
        modified = " ●", -- Text to show when the file is modified.
        readonly = " 󰈡", -- Text to show when the file is non-modifiable or readonly.
        unnamed = "[No Name]", -- Text to show for unnamed buffers.
        newfile = "[New]", -- Text to show for newly created file before first write
      },
      fmt = function(filepath)
        local obsidian_prefix = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/"
        if filepath:find(obsidian_prefix, 1, true) then
          return "..." .. filepath:sub(#obsidian_prefix)
        end
        return filepath
      end,
    }

    local function spell_status()
      if vim.wo.spell then
        local langs = table.concat(vim.opt.spelllang:get(), ",")
        return " " .. langs
      else
        return " "
      end
    end

    local function lsp_clients()
      local clients = vim.lsp.get_clients({ bufnr = 0 })
      if not clients or #clients == 0 or _G.IS_LEETCODE_SESSION then
        return " "
      end

      local names = {}
      for _, client in ipairs(clients) do
        local client_name = client.name  -- not to modify the original name

        if client.name == "GitHub Copilot" then
          -- if copilot is disabled, skip it
          if vim.g.copilot_enabled == false then
            goto continue
          end
          client_name = "Copilot" -- shorten the name on display
        end

        table.insert(names, client_name)
        ::continue::
      end

      -- if after filtering there are no names, return just the icon
      if #names == 0 then
        return " "
      end

      return " " .. table.concat(names, ", ")
    end

    local function active_linters()
      local lint = require("lint")
      local buf_ft = vim.bo.filetype
      local linters = lint.linters_by_ft[buf_ft] or {}

      if #linters == 0 or _G.IS_LEETCODE_SESSION then
        return "󱪙 "
      end
      return "󱪙 " .. table.concat(linters, ", ")
    end

    require("lualine").setup({
      options = {
        icons_enabled = true,
        theme = custom_theme,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        -- // ', right = ''
        disabled_filetypes = {
          statusline = { "neo-tree" },
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        always_show_tabline = true,
        globalstatus = false,
        refresh = {
          statusline = 100,
          tabline = 100,
          winbar = 100,
        },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { custom_filename },
        lualine_x = { spell_status, lsp_clients, active_linters, "filetype" }, -- "encoding", "fileformat"
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { custom_filename },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {
        "neo-tree",
        "quickfix",
        "trouble",
        "mason",
        "lazy",
        "fzf",
      },
    })

    -- Make NeoTree inactive statusline's strange black background disappear
    vim.api.nvim_set_hl(0, "NeoTreeStatusLineNC", { link = "StatusLine" })
  end,
}
