---@diagnostic disable: missing-fields, unused-local
local computer_name = vim.fn.system("scutil --get ComputerName | tr -d '\n'")
local roger_config = require("roger.core.config")
if computer_name ~= roger_config.computer_name_ob then
  return {}
end

return {
  -- "epwalsh/obsidian.nvim",
  "obsidian-nvim/obsidian.nvim",
  dependencies = {},
  config = function()
    local obsidian = require("obsidian")
    local keymaps = require("roger.core.keymaps")
    keymaps.obsidian()

    obsidian.setup({
      legacy_commands = false,
      workspaces = {
        {
          name = "Workspace",
          path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Workspace",
        },
        {
          name = "Workspace-Archive",
          path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Workspace-Archive",
        },
      },

      -- Optional, if you keep notes in a specific subdirectory of your vault.
      notes_subdir = "",

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
      --   -- Optional, if you want `Obsidian yesterday` to return the last work day or `Obsidian tomorrow` to return the next work day.
      --   workdays_only = true,
      -- },

      -- Completion is served by the built-in obsidian-ls LSP server
      -- It flows through nvim-cmp `cmp-nvim-lsp` source
      completion = {
        min_chars = 2, -- Trigger completion at 2 chars.
      },

      -- Where to put new notes. Valid options are
      -- _ "current_dir" - put new notes in same directory as the current buffer.
      -- _ "notes_subdir" - put new notes in the default notes subdirectory.
      new_notes_location = "current_dir",

      -- Optional, customize how note IDs are generated given an optional title.
      note_id_func = function(title)
        -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
        -- In this case a note with the title 'My new note' will be given an ID that looks
        -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
        local suffix = ""
        if title ~= nil then
          -- If title is given, transform it into valid file name.
          -- Keep spaces, ':', '_', and '-', remove only invalid filename characters
          suffix = title:gsub("[^A-Za-z0-9:_ -]", "")
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

      -- style       = "wiki" | "markdown" | function(opts) -> string
      -- format      = "shortest" | "relative" | "absolute" (path form inside links)
      -- auto_update = rewrite links pointing to a note when it is renamed
      link = {
        style = "wiki",
        format = "shortest",
        auto_update = true,
      },

      -- enabled = false: obsidian never adds or rewrites the YAML frontmatter block.
      -- To let it manage frontmatter, set enabled = true and optionally provide
      -- `func` (fun(note) -> table) and `sort` (key order, e.g. { "id", "aliases", "tags" }).
      frontmatter = {
        enabled = false,
      },

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

      -- How links and images are opened (used for URLs and image files).
      open = {
        use_advanced_uri = false,
        func = vim.ui.open,
      },

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

      -- sort_by: "path" | "modified" | "accessed" | "created".
      search = {
        sort_by = "modified",
        sort_reversed = true,
        max_lines = 1000,
      },

      -- Optional, determines how certain commands open notes. The valid options are:
      -- 1. "current" (the default) - to always open in the current window
      -- 2. "vsplit" - only open in a vertical split if a vsplit does not exist.
      -- 3. "hsplit" - only open in a horizontal split if a hsplit does not exist.
      -- 4. "vsplit_force" - always open a new vertical split if the file is not in the adjacent vsplit.
      -- 5. "hsplit_force" - always open a new horizontal split if the file is not in the adjacent
      open_notes_in = "current",

      -- All callbacks are optional.
      callbacks = {
        -- Runs right after obsidian.setup() finishes.
        -- post_setup = function() end,

        -- Runs when `Note.create` builds a note object (opts.scope defaults to "plain").
        -- create_note = function(note, opts) end,

        -- Runs each time you enter / leave a note buffer.
        -- enter_note = function(note) end,
        -- leave_note = function(note) end,

        -- Runs after an attachment is added (e.g. a pasted image).
        -- add_attachment = function(path, ctx) end,

        -- Runs anytime the active workspace is set / changed.
        -- post_set_workspace = function(workspace) end,

        -- Runs right before writing a note buffer.
        -- Strip trailing whitespace (EOL) and blank lines at EOF.
        pre_write_note = function(note)
          local bufnr = vim.api.nvim_get_current_buf()
          local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
          for i, line in ipairs(lines) do
            lines[i] = line:gsub("%s+$", "")
          end
          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

          local total = #lines
          local last = total
          while last > 0 and lines[last]:match("^%s*$") do
            last = last - 1
          end
          if last < total then
            vim.api.nvim_buf_set_lines(bufnr, last, total, false, {})
          end
        end,
      },

      -- Optional, configure additional syntax highlighting / extmarks.
      -- This requires you have `conceallevel` set to 1 or 2. See `:help conceallevel` for more details.
      ui = {
        enable = false,
      },

      -- Specify how to handle attachments.
      attachments = {
        -- The default folder to place images in via `:ObsidianPasteImg`.
        -- If this is a relative path it will be interpreted as relative to the vault root.
        -- You can always override this per image by passing a full path to the command instead of just a filename.
        folder = "./assets",

        -- Optional, customize the default name or prefix when pasting images via `:ObsidianPasteImg`.
        img_name_func = function()
          -- Prefix image names with timestamp.
          return string.format("%s-", os.time())
        end,

        -- Text inserted in the note when pasting an image; receives the image `obsidian.Path`.
        img_text_func = function(path)
          return string.format("![%s](%s)", path.name, path)
        end,
      },

      footer = {
        enabled = true,
        format = ": {{backlinks}} backlinks  {{words}} words  {{chars}} chars :",
        hl_group = "Comment",
        separator = false, -- string.rep("-", 80),
      },
    })

    -- rename calls save_to_buffer without asking should_save_frontmatter(),
    -- so it writes frontmatter even when it is disabled.
    -- Drop this once upstream PR #741 lands.
    local Note = require("obsidian.note")
    local save_to_buffer = Note.save_to_buffer
    Note.save_to_buffer = function(self, opts)
      opts = opts or {}
      if opts.insert_frontmatter == nil then
        opts.insert_frontmatter = self:should_save_frontmatter()
      end
      return save_to_buffer(self, opts)
    end

    vim.api.nvim_create_user_command("ObsidianCustomSwitch", function()
      local q = vim.fn.input("[Obsidian Switch] Query: ")
      vim.cmd("Obsidian quick_switch " .. q)
    end, { desc = "Quick switch by query" })
  end,
}
