---@diagnostic disable: missing-fields, unused-local
local computer_name = vim.fn.system("scutil --get ComputerName | tr -d '\n'")
local roger_config = require("roger.core.config")
if computer_name ~= roger_config.computer_name_ob then
  return {}
end

return {
  -- "epwalsh/obsidian.nvim",
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local obsidian = require("obsidian")
    local keymaps = require("roger.core.keymaps")
    keymaps.obsidian()

    obsidian.setup({
      workspaces = {
        {
          name = "Workspace",
          path = "/Users/roger/Library/Mobile Documents/iCloud~md~obsidian/Documents/Workspace",
        },
        {
          name = "Workspace-Archive",
          path = "/Users/roger/Library/Mobile Documents/iCloud~md~obsidian/Documents/Workspace-Archive",
        },
      },

      log_level = vim.log.levels.INFO, -- set the log level for obsidian.nvim.

      -- daily_notes = {
      --   -- Optional, if you keep daily notes in a separate directory.
      --   folder = "notes/dailies",
      --   -- Optional, if you want to change the date format for the ID of daily notes.
      --   date_format = "%Y-%m-%d",
      --   -- Optional, if you want to change the date format of the default alias of daily notes.
      --   alias_format = "%B %-d, %Y",
      --   -- Optional, default tags to add to each new daily note created.
      --   default_tags = { "daily-notes" },
      --   -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
      --   template = nil,
      -- },

      -- completion of wiki links, local markdown links, and tags using nvim-cmp.
      completion = {
        nvim_cmp = true, -- Set to false to disable completion.
        min_chars = 2, -- Trigger completion at 2 chars.
      },

      -- Optional, configure key mappings. These are the defaults. If you don't want to set any keymappings this
      -- way then set 'mappings = {}'.
      mappings = keymaps.obsidian_table(),

      -- Where to put new notes. Valid options are
      notes_subdir = "",
      --  * "current_dir" - put new notes in same directory as the current buffer.
      --  * "notes_subdir" - put new notes in the default notes subdirectory.
      new_notes_location = "current_dir",

      -- Optional, customize how note IDs are generated given an optional title.
      note_id_func = function(title)
        -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
        -- In this case a note with the title 'My new note' will be given an ID that looks
        -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
        local suffix = ""
        if title ~= nil then
          -- If title is given, transform it into valid file name.
          suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9_-]", "")
        else
          -- If title is nil, just add 4 random uppercase letters to the suffix.
          for _ = 1, 4 do
            suffix = suffix .. string.char(math.random(65, 90))
          end
        end
        return suffix
      end,

      -- Optional, customize how note file names are generated given the ID, target directory, and title.
      note_path_func = function(spec)
        -- This is equivalent to the default behavior.
        local path = spec.dir / tostring(spec.id)
        return path:with_suffix(".md")
      end,

      -- Optional, customize how wiki links are formatted. You can set this to one of:
      --  * "use_alias_only", e.g. '[[Foo Bar]]'
      --  * "prepend_note_id", e.g. '[[foo-bar|Foo Bar]]'
      --  * "prepend_note_path", e.g. '[[foo-bar.md|Foo Bar]]'
      --  * "use_path_only", e.g. '[[foo-bar.md]]'
      -- Or you can set it to a function that takes a table of options and returns a string, like this:
      wiki_link_func = function(opts)
        return require("obsidian.util").wiki_link_id_prefix(opts)
      end,

      -- Optional, customize how markdown links are formatted.
      markdown_link_func = function(opts)
        return require("obsidian.util").markdown_link(opts)
      end,

      -- Either 'wiki' or 'markdown'.
      preferred_link_style = "wiki",

      -- Optional, boolean or a function that takes a filename and returns a boolean.
      -- `true` indicates that you don't want obsidian.nvim to manage frontmatter.
      disable_frontmatter = true,

      -- Optional, alternatively you can customize the frontmatter data.
      note_frontmatter_func = function(note)
        -- Add the title of the note as an alias.
        if note.title then
          note:add_alias(note.title)
        end

        local out = { id = note.id, aliases = note.aliases, tags = note.tags }

        -- `note.metadata` contains any manually added fields in the frontmatter.
        -- So here we just make sure those fields are kept in the frontmatter.
        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          for k, v in pairs(note.metadata) do
            out[k] = v
          end
        end

        return out
      end,

      -- Optional, for templates (see below).
      templates = {
        folder = "900_Others/templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
        -- A map for custom variables, the key should be the variable and the value a function
        substitutions = {
          parent_file = function()
            local buf_path = vim.api.nvim_buf_get_name(0) -- get buffer full name
            if buf_path == "" then
              return ""
            end

            local dir_path = vim.fn.fnamemodify(buf_path, ":p:h") -- e.g. .../320_Account
            local dir_name = vim.fn.fnamemodify(buf_path, ":p:h:t") -- e.g. 320_Account

            local parent_basename = dir_name:gsub("_", "-", 1)
            local parent_fullpath = dir_path .. "/" .. parent_basename .. ".md"

            if vim.uv.fs_stat(parent_fullpath) then
              return parent_basename
            else
              return ""
            end
          end,
        },
      },

      -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
      -- URL it will be ignored but you can customize this behavior here.
      follow_url_func = function(url)
        -- Open the URL in the default web browser.
        -- vim.fn.jobstart({ "open", url }) -- Mac OS
        -- vim.fn.jobstart({"xdg-open", url})  -- linux
        -- vim.cmd(':silent exec "!start ' .. url .. '"') -- Windows
        vim.ui.open(url) -- need Neovim 0.10.0+
      end,

      follow_img_func = function(img)
        local current_dir = vim.fn.expand("%:p:h")
        local img_name = vim.fn.fnamemodify(img, ":t")
        local img_abs_path = vim.fn.resolve(current_dir .. "/assets/" .. img_name)

        -- 用 qlmanage 開啟圖片（Quick Look）
        vim.fn.jobstart({ "qlmanage", "-p", img_abs_path }, { detach = true })

        -- 延遲一段時間，讓 Quick Look 有足夠時間啟動，
        -- 然後利用 osascript 強制把 Quick Look 的視窗置頂
        vim.defer_fn(function()
          vim.fn.jobstart({
            "osascript",
            "-e",
            'tell application "System Events" to set frontmost of the first process whose name is "qlmanage" to true',
          }, { detach = true })
        end, 100) -- 延遲時間可依需求調整（單位：毫秒）

        -- print("Opening image with Quick Look:", img_abs_path)
      end,

      -- -- Optional, by default when you use `:ObsidianFollowLink` on a link to an image
      -- -- file it will be ignored but you can customize this behavior here.
      -- follow_img_func = function(img)
      --   vim.fn.jobstart({ "qlmanage", "-p", img }) -- Mac OS quick look preview
      --   -- vim.fn.jobstart({"xdg-open", url})  -- linux
      --   -- vim.cmd(':silent exec "!start ' .. url .. '"') -- Windows
      -- end,

      -- Optional, set to true if you use the Obsidian Advanced URI plugin.
      -- https://github.com/Vinzent03/obsidian-advanced-uri
      use_advanced_uri = false,

      -- Optional, set to true to force ':ObsidianOpen' to bring the app to the foreground.
      open_app_foreground = true,

      picker = {
        -- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', or 'mini.pick'.
        name = "telescope.nvim",
        -- Optional, configure key mappings for the picker. These are the defaults.
        -- Not all pickers support all mappings.
        note_mappings = {
          -- Create a new note from your query.
          new = "<C-x>",
          -- Insert a link to the selected note.
          insert_link = "<C-l>",
        },
        tag_mappings = {
          -- Add tag(s) to current note.
          tag_note = "<C-x>",
          -- Insert a tag at the current location.
          insert_tag = "<C-l>",
        },
      },

      -- Optional, sort search results by "path", "modified", "accessed", or "created".
      -- The recommend value is "modified" and `true` for `sort_reversed`, which means, for example,
      -- that `:ObsidianQuickSwitch` will show the notes sorted by latest modified time
      sort_by = "modified",
      sort_reversed = true,

      -- Set the maximum number of lines to read from notes on disk when performing certain searches.
      search_max_lines = 1000,

      -- Optional, determines how certain commands open notes. The valid options are:
      -- 1. "current" (the default) - to always open in the current window
      -- 2. "vsplit" - to open in a vertical split if there's not already a vertical split
      -- 3. "hsplit" - to open in a horizontal split if there's not already a horizontal split
      open_notes_in = "current",

      -- Optional, define your own callbacks to further customize behavior.
      callbacks = {
        -- Runs at the end of `obsidian.setup()`.
        post_setup = function(client) end,

        -- Runs anytime you enter the buffer for a note.
        enter_note = function(client, note) end,

        -- Runs anytime you leave the buffer for a note.
        leave_note = function(client, note) end,

        -- Runs right before writing the buffer for a note.
        -- NOTE: Delete space at the EOL, Delete blank lines at the EOF
        pre_write_note = function(client, note)
          local bufnr = vim.api.nvim_get_current_buf()
          -- 1) 取出全部行
          local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

          -- 2) 刪除每行末尾多餘的空白
          for i, line in ipairs(lines) do
            lines[i] = line:gsub("%s+$", "")
          end
          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

          -- 3) 刪除尾端多餘的空行
          local total = #lines
          local last = total
          while last > 0 and lines[last]:match("^%s*$") do
            last = last - 1
          end
          if last < total then
            -- 從第 last (0-based) 行開始，一口氣刪到檔尾
            vim.api.nvim_buf_set_lines(bufnr, last, total, false, {})
          end
        end,

        -- Runs anytime the workspace is set/changed.
        post_set_workspace = function(client, workspace) end,
      },

      -- Optional, configure additional syntax highlighting / extmarks.
      -- This requires you have `conceallevel` set to 1 or 2. See `:help conceallevel` for more details.
      ui = {
        enable = false, -- set to false to disable all additional syntax features
        update_debounce = 200, -- update delay after a text change (in milliseconds)
        max_file_length = 5000, -- disable UI features for files with more than this many lines
        -- Define how various check-boxes are displayed
        checkboxes = {
          -- NOTE: the 'char' value has to be a single character, and the highlight groups are defined below.
          [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
          ["x"] = { char = "", hl_group = "ObsidianDone" },
          [">"] = { char = "", hl_group = "ObsidianRightArrow" },
          ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
          ["!"] = { char = "", hl_group = "ObsidianImportant" },
          -- Replace the above with this if you don't have a patched font:
          -- [" "] = { char = "☐", hl_group = "ObsidianTodo" },
          -- ["x"] = { char = "✔", hl_group = "ObsidianDone" },

          -- You can also add more custom ones...
        },
        -- Use bullet marks for non-checkbox lists.
        bullets = { char = "•", hl_group = "ObsidianBullet" },
        external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
        -- Replace the above with this if you don't have a patched font:
        -- external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
        reference_text = { hl_group = "ObsidianRefText" },
        highlight_text = { hl_group = "ObsidianHighlightText" },
        tags = { hl_group = "ObsidianTag" },
        block_ids = { hl_group = "ObsidianBlockID" },
        hl_groups = {
          -- The options are passed directly to `vim.api.nvim_set_hl()`. See `:help nvim_set_hl`.
          ObsidianTodo = { bold = true, fg = "#f78c6c" },
          ObsidianDone = { bold = true, fg = "#89ddff" },
          ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
          ObsidianTilde = { bold = true, fg = "#ff5370" },
          ObsidianImportant = { bold = true, fg = "#d73128" },
          ObsidianBullet = { bold = true, fg = "#89ddff" },
          ObsidianRefText = { underline = true, fg = "#c792ea" },
          ObsidianExtLinkIcon = { fg = "#c792ea" },
          ObsidianTag = { italic = true, fg = "#89ddff" },
          ObsidianBlockID = { italic = true, fg = "#89ddff" },
          ObsidianHighlightText = { bg = "#75662e" },
        },
      },

      -- Specify how to handle attachments.
      attachments = {
        -- The default folder to place images in via `:ObsidianPasteImg`.
        -- If this is a relative path it will be interpreted as relative to the vault root.
        -- You can always override this per image by passing a full path to the command instead of just a filename.
        -- img_folder = "assets/imgs", -- This is the default

        -- Optional, customize the default name or prefix when pasting images via `:ObsidianPasteImg`.
        img_name_func = function()
          -- Prefix image names with timestamp.
          return string.format("%s-", os.time())
        end,

        -- A function that determines the text to insert in the note when pasting an image.
        -- It takes two arguments, the `obsidian.Client` and an `obsidian.Path` to the image file.
        -- This is the default implementation.
        img_text_func = function(client, path)
          path = client:vault_relative_path(path) or path
          return string.format("![%s](%s)", path.name, path)
        end,
      },
    })

    -- NOTE: Create `:ObsidianRenameID` to make 'renaming' apply `note_id_func`
    local client = obsidian.get_client()
    vim.api.nvim_create_user_command("ObsidianCustomRename", function()
      local title = vim.fn.input("[Obsidian Rename] New File Name: ")
      if title == "" then
        return
      end
      local new_id = client.opts.note_id_func(title)
      client:command("rename", { args = new_id })
    end, {
      nargs = 0,
      desc = "Interactive rename current note with note_id_func",
    })
    vim.api.nvim_create_user_command("ObsidianCustomSwitch", function()
      local title = vim.fn.input("[Obsidian Switch] Note ID: ")
      if title == "" then
        return
      end
      client:command("quick_switch", { args = title })
    end, {
      nargs = 0,
      desc = "Switch note by ID",
    })
  end,
}
