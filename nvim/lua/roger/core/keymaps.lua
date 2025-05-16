local M = {}

M.general = function()
  -- using "jk" as <ESC> in INSERT, VISUAL, COMMAND, TERMINAL are configured in "better-escape" module
  vim.keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights", silent = true })

  vim.keymap.set("n", "<leader>ww", ":w<CR>", { desc = "Save file (:w) ", silent = true })
  vim.keymap.set("n", "<leader>q<space>", ":q<CR>", { desc = "Quit current Nvim window (:q)", silent = true })
  vim.keymap.set("n", "<leader>qq", ":qa<CR>", { desc = "Quit all Nvim windows (:qa)", silent = true })
  vim.keymap.set("n", "<leader>e", ":e<CR>", { desc = "Edit the file (Refresh)", silent = true })

  -- centered vertical movement
  vim.keymap.set("n", "<C-u>", "<C-u>zz", { remap = false, desc = "Scoll up half page" })
  vim.keymap.set("n", "<C-d>", "<C-d>zz", { remap = false, desc = "Scoll down half page" })
  vim.keymap.set("n", "n", "nzz", { remap = false, desc = "See next search result" })
  vim.keymap.set("n", "N", "Nzz", { remap = false, desc = "See previous search result" })

  vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor pos" })

  -- Misspell correction
  -- "z=": check misspell correction options
  -- "zg": add the word into good word pool
  vim.keymap.set("n", "z-", ":spellr<CR>", { desc = "Redo spell correction in current file", silent = true })

  -- INFO: Need to set "option" key as "Meta" or "ESC+" key to function
  -- Move current line/selection up or down
  vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
  vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up", silent = true })
  vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })
  vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })

  -- Duplicate current line up or down
  vim.keymap.set("n", "<A-S-j>", "mzyyp`zj", { desc = "Duplicate line below", silent = true })
  vim.keymap.set("n", "<A-S-k>", "mzyyP`zk", { desc = "Duplicate line above", silent = true })
  vim.keymap.set("v", "<A-S-j>", "y'>p`[V`]", { desc = "Duplicate selection below", silent = true })
  vim.keymap.set("v", "<A-S-k>", "y'<P`[V`]", { desc = "Duplicate selection above", silent = true })

  -- Insert blank line above/below with still cursor
  vim.keymap.set("n", "<A-o>", "mzo<Esc>`z", { desc = "Insert blank line below" })
  vim.keymap.set("n", "<A-O>", "mzO<Esc>`z", { desc = "Insert blank line above" })

  -- yank to and paste from system clipboard
  vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { silent = true })
  vim.keymap.set({ "n", "v" }, "<leader>Y", '"+Y', { silent = true })
  vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', { silent = true })
  vim.keymap.set({ "n", "v" }, "<leader>P", '"+P', { silent = true })
  vim.keymap.set({ "n", "v" }, "<leader>d", '"+d', { silent = true })
  vim.keymap.set({ "n", "v" }, "<leader>D", '"+D', { silent = true })

  -- search and replace
  vim.keymap.set({ "v" }, "/", '"vy/<C-r>v', { desc = "search for selected part", noremap = true })
  vim.keymap.set("v", "<leader>rg", function()
    vim.cmd('silent! normal! "zy') -- yank visual to register z
    local pattern = vim.fn.escape(vim.fn.getreg("z"), "\\/") -- take string out and escape needed words
    -- prompt user to input what to change to
    vim.fn.inputsave()
    local repl = vim.fn.input("Replace with: ")
    vim.fn.inputrestore()
    local cmd = string.format("%%s/\\V%s/%s/g", pattern, vim.fn.escape(repl, "\\/"))
    vim.cmd(cmd)
  end, { desc = "Replace ALL occurrences of visual selection" })
  vim.keymap.set("v", "<leader>rc", function()
    vim.cmd('silent! normal! "zy')
    local pattern = vim.fn.escape(vim.fn.getreg("z"), "\\/")
    vim.fn.inputsave()
    local repl = vim.fn.input("Replace with: ")
    vim.fn.inputrestore()
    local cmd = string.format("%%s/\\V%s/%s/gc", pattern, vim.fn.escape(repl, "\\/"))
    vim.cmd(cmd)
  end, { desc = "Replace (confirm) occurrences of visual selection" })

  -- increment/decrement numbers
  vim.keymap.set({ "n", "v" }, "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement
  vim.keymap.set({ "n", "v" }, "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
  vim.keymap.set({ "n", "v" }, "g<leader>-", "g<C-x>", { desc = "Decrement all numbers" }) -- decrement
  vim.keymap.set({ "n", "v" }, "g<leader>+", "g<C-a>", { desc = "Increment all numbers" }) -- increment

  -- window management
  vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
  vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
  vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
  vim.keymap.set("n", "<leader>sx", ":close<CR>", { desc = "Close current split", silent = true })
  vim.keymap.set("n", "<leader>sm", ":MaximizerToggle<CR>", { desc = "Max/min a split", silent = true })
  vim.keymap.set("n", "<leader>s<RIGHT>", "2<C-w>>", { desc = "Increase split width" })
  vim.keymap.set("n", "<leader>s<LEFT>", "2<C-w><", { desc = "Decrease split width" })
  vim.keymap.set("n", "<leader>s<UP>", "4<C-w>+", { desc = "Increase split height" })
  vim.keymap.set("n", "<leader>s<DOWN>", "4<C-w>-", { desc = "Decrease split height" })

  -- tab management
  vim.keymap.set("n", "<leader>tn", ":tabnew<CR>", { desc = "Open new tab", silent = true })
  vim.keymap.set("n", "<leader>tx", ":tabclose<CR>", { desc = "Close current tab", silent = true })
  vim.keymap.set("n", "<leader>tk", ":tabn<CR>", { desc = "Go to next tab", silent = true })
  vim.keymap.set("n", "<leader>tj", ":tabp<CR>", { desc = "Go to previous tab", silent = true })
  vim.keymap.set("n", "<leader>tp", ":BufferLinePick<CR>", { desc = "Pick tab", silent = true })
  vim.keymap.set("n", "<leader>tf", ":tabnew %<CR>", { desc = "Open current buffer in new tab", silent = true })

  -- spell
  vim.keymap.set("n", "<leader>ss", function()
    vim.wo.spell = not vim.wo.spell
    if vim.wo.spell then
      vim.notify("Spell ON", vim.log.levels.INFO)
    else
      vim.notify("Spell OFF", vim.log.levels.INFO)
    end
  end, { desc = "Toggle spell checking" })

  -- highlights from treesitter
  vim.keymap.set(
    "n",
    "<leader>gh",
    ":echo luaeval('vim.inspect(vim.treesitter.get_captures_at_cursor(0))')<CR>",
    { desc = "Show highlight from TS", silent = true }
  )

  local open_in_file_manager = function(file_path)
    local sysname = vim.loop.os_uname().sysname
    if sysname == "Darwin" then -- MacOS: by Finder
      vim.fn.jobstart({ "open", "-R", file_path }, { detach = true })
    elseif sysname == "Linux" then -- Linux: by xdg-open
      local folder = vim.fn.fnamemodify(file_path, ":h")
      vim.fn.jobstart({ "xdg-open", folder }, { detach = true })
    else
      vim.notify([["Open in File Manager" is not supported in this OS: ]] .. sysname, vim.log.levels.WARN)
    end
  end
  vim.keymap.set("n", "<leader>ff", function()
    open_in_file_manager(vim.fn.expand("%:p"))
  end, { desc = "Open file in Finder", noremap = true, silent = true })

  -- from comment.lua
  -- 'gc' + motion.   Ex. gc3j(to 3 lines below), gcG(to EOF), gcc(one line)
end

M.folding = function()
  -- `normal`: executes the command and respects any mappings that might be defined.
  -- `normal!`: executes the command in a "raw" mode, ignoring any mappings.

  vim.keymap.set({ "n", "v" }, "gk", function()
    -- `?` - Start a search backwards from the current cursor position.
    -- `^` - Match the beginning of a line.
    -- `#` - Match 1 # symbols
    -- `\\+` - Match one or more occurrences of prev element (#)
    -- `\\s` - Match exactly one whitespace character following the hashes
    -- `.*` - Match any characters (except newline) following the space
    -- `$` - Match extends to end of line
    -- vim.cmd("silent! ?^#\\+\\s.*$")
    -- vim.cmd("nohlsearch") -- Clear the search highlight
    vim.fn.search("^#\\+\\s.*$", "bW") -- "b": search back, "W": touch TOP will not go find END
    vim.cmd("nohlsearch")
  end, { desc = "Go to previous MD header" })

  vim.keymap.set({ "n", "v" }, "gj", function()
    -- `/` - Start a search forwards from the current cursor position.
    -- `^` - Match the beginning of a line.
    -- `#` - Match 1 # symbols
    -- `\\+` - Match one or more occurrences of prev element (#)
    -- `\\s` - Match exactly one whitespace character following the hashes
    -- `.*` - Match any characters (except newline) following the space
    -- `$` - Match extends to end of line
    -- vim.cmd("silent! /^#\\+\\s.*$")
    -- vim.cmd("nohlsearch")
    vim.fn.search("^#\\+\\s.*$", "W")
    vim.cmd("nohlsearch")
  end, { desc = "Go to next MD header" })

  vim.keymap.set("n", "<CR>", function()
    local line = vim.fn.line(".") -- Get the current line number
    local foldlevel = vim.fn.foldlevel(line) -- Get the fold level of the current line
    if foldlevel == 0 then
      vim.notify("No fold found", vim.log.levels.INFO)
    else
      vim.cmd("normal! za")
      vim.cmd("normal! zz") -- center the cursor line on screen
    end
  end, { desc = "Toggle fold" })

  local function fold_headings_of_level(level)
    vim.cmd("normal! gg")
    local total_lines = vim.fn.line("$") -- get the total number of lines
    for line = 1, total_lines do
      local line_content = vim.fn.getline(line) -- Get the content of the current line
      -- "^" -> Ensures the match is at the start of the line
      -- string.rep("#", level) -> Creates a string with 'level' number of "#" characters
      -- "%s" -> Matches any whitespace character after the "#" characters
      -- So this will match `## `, `### `, `#### ` for example, which are markdown headings
      if line_content:match("^" .. string.rep("#", level) .. "%s") then
        vim.fn.cursor(line, 1) -- Move the cursor to the current line
        -- Fold the heading if it matches the level
        if vim.fn.foldclosed(line) == -1 then
          vim.cmd("normal! za")
        end
      end
    end
  end

  local function fold_markdown_headings(levels)
    local saved_view = vim.fn.winsaveview() -- save the view now, in order to jump back
    for _, level in ipairs(levels) do
      fold_headings_of_level(level)
    end
    vim.cmd("nohlsearch")
    vim.fn.winrestview(saved_view) -- Restore the view to jump to where I was
  end

  vim.keymap.set("n", "zu", function()
    vim.cmd("silent update") -- save only if file being modified
    vim.cmd("edit!") -- Reloads the file to reflect the changes
    vim.cmd("normal! zR") -- Unfold everything
    vim.cmd("normal! zz") -- center the cursor line on screen
  end, { desc = "Unfold all" })

  vim.keymap.set("n", "zi", function()
    vim.cmd("silent update")
    vim.cmd("normal gk")
    vim.cmd("normal! za") -- fold the line under cursor
    vim.cmd("normal! zz")
  end, { desc = "Fold the header currently in" })

  vim.keymap.set("n", "zj", function()
    vim.cmd("silent update")
    vim.cmd("edit!")
    vim.cmd("normal! zR")
    fold_markdown_headings({ 6, 5, 4, 3, 2, 1 })
    vim.cmd("normal! zz")
  end, { desc = "Fold all headers level 1↑" })

  vim.keymap.set("n", "zk", function()
    vim.cmd("silent update")
    vim.cmd("edit!")
    vim.cmd("normal! zR")
    fold_markdown_headings({ 6, 5, 4, 3, 2 })
    vim.cmd("normal! zz")
  end, { desc = "Fold all headers level 2↑" })

  vim.keymap.set("n", "zl", function()
    vim.cmd("silent update")
    vim.cmd("edit!")
    vim.cmd("normal! zR")
    fold_markdown_headings({ 6, 5, 4, 3 })
    vim.cmd("normal! zz")
  end, { desc = "Fold all headers level 3↑" })

  vim.keymap.set("n", "z;", function()
    vim.cmd("silent update")
    vim.cmd("edit!")
    vim.cmd("normal! zR")
    fold_markdown_headings({ 6, 5, 4 })
    vim.cmd("normal! zz")
  end, { desc = "Fold all headers level 4↑" })
end

M.lsp = function()
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
      -- local client = vim.lsp.get_client_by_id(ev.data.client_id)
      -- if client then
      --   vim.notify("LSP " .. client.name .. " attached to buffer " .. ev.buf, vim.log.levels.INFO)
      -- end

      local bufopts = { noremap = true, silent = true, buffer = ev.buf }
      local function with_desc(desc)
        return vim.tbl_extend("force", bufopts, { desc = desc })
      end
      vim.keymap.set("n", "K", vim.lsp.buf.hover, with_desc("Show hover Info"))
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, with_desc("Go to declaration"))
      vim.keymap.set("n", "gd", ":Telescope lsp_definitions<CR>", with_desc("Show LSP definitions"))
      vim.keymap.set("n", "gi", ":Telescope lsp_implementations<CR>", with_desc("Show LSP implementations"))
      vim.keymap.set("n", "gr", ":Telescope lsp_references<CR>", with_desc("Show LSP references"))
      vim.keymap.set("n", "gt", ":Telescope lsp_type_definitions<CR>", with_desc("Show LSP type definitions"))
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, with_desc("Code action"))
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, with_desc("Rename symbol"))
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, with_desc("Go to next diagnostic"))
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, with_desc("Go to previous diagnostic"))
      vim.keymap.set("n", "<leader>rs", ":LspRestart<CR>", with_desc("Restart LSP"))
    end,
  })
end

M.formatting = function()
  local conform = require("conform")
  vim.keymap.set({ "n", "v" }, "<leader>gf", function()
    conform.format({
      lsp_fallback = true,
      async = false,
      timeout_ms = 1000,
    })
  end, { desc = "Format file or range (in v)" })
end

M.linting = function()
  local lint = require("lint")
  vim.keymap.set("n", "<leader>ll", function()
    lint.try_lint()
  end, { desc = "Trigger linting for current file" })
end

M.neo_tree = function()
  vim.g.neo_tree_is_open = false

  local function open_neo_tree()
    vim.cmd("silent Neotree reveal")
    vim.g.neo_tree_is_open = true
  end

  local function close_neo_tree()
    vim.cmd("silent Neotree close")
    vim.g.neo_tree_is_open = false
  end

  local function toggle_neo_tree()
    if vim.g.neo_tree_is_open then
      close_neo_tree()
    else
      open_neo_tree()
    end
  end

  local function switch_neo_tree()
    -- 獲取當前的 Tab 頁索引
    local current_tab = vim.api.nvim_get_current_tabpage()

    -- 獲取當前 Tab 的所有窗口
    local tab_wins = vim.api.nvim_tabpage_list_wins(current_tab)
    local neo_tree_win = nil

    -- 找到當前 Tab 中的 Neo-tree 窗口
    for _, win in ipairs(tab_wins) do
      local buf = vim.api.nvim_win_get_buf(win)
      local buf_name = vim.api.nvim_buf_get_name(buf)
      if buf_name:match("neo%-tree filesystem") then
        neo_tree_win = win
        break
      end
    end

    if neo_tree_win then
      -- Neo-tree 在當前 Tab 中已打開，切換到該窗口或關閉
      local current_win = vim.api.nvim_get_current_win()
      if neo_tree_win == current_win then
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype ~= "neo-tree" then
            vim.api.nvim_set_current_win(win) -- 切過去
            return
          end
        end
      else
        vim.api.nvim_set_current_win(neo_tree_win)
      end
    else
      open_neo_tree()
    end
  end

  vim.keymap.set("n", "<leader>j", switch_neo_tree, { desc = "Switch between file and Neo-tree" })
  vim.keymap.set("n", "<leader>J", toggle_neo_tree, { desc = "Toggle Neo-tree" })

  vim.api.nvim_create_autocmd({ "TabEnter", "TabNewEntered" }, {
    callback = function()
      -- 檢查目前 tab 是否已經有 Neo-tree 視窗
      local has_neo = false
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.api.nvim_buf_get_name(buf):match("neo%-tree filesystem") then
          has_neo = true
          break
        end
      end

      if vim.g.neo_tree_is_open and not has_neo then
        vim.cmd("silent Neotree show left")
      elseif not vim.g.neo_tree_is_open and has_neo then
        vim.cmd("silent Neotree close")
      end
    end,
  })

  vim.api.nvim_create_autocmd("TabLeave", {
    callback = function()
      -- 若當前視窗的 filetype 是 neo-tree，就換視窗
      if vim.bo.filetype == "neo-tree" then
        -- 1. 在此 tab 內找第一個非 neo-tree 視窗
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype ~= "neo-tree" then
            vim.api.nvim_set_current_win(win) -- 切過去
            return
          end
        end
        -- 2. 如果整個 tab 都只剩側欄，就新開一個空白 buffer
        vim.cmd("enew | wincmd p")
      end
    end,
  })
end

M.telescope = function()
  local builtin = require("telescope.builtin")
  vim.keymap.set("n", "<leader>fj", ":Telescope find_files hidden=true<CR>", { desc = "Find files in cwd", silent = true })
  vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Find diagnostics" })
  vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Find recent files" })
  vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Grep string in cwd" })
  -- vim.keymap.set("n", "<leader>fc", builtin.grep_string, { desc = "Find string under cursor" })
  vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
  vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
  vim.keymap.set("n", "<leader>fH", ":Telescope highlights<CR>", { desc = "Telescope highlights", silent = true })
  vim.keymap.set("n", "<leader>ft", ":TodoTelescope<CR>", { desc = "Find todos", silent = true })
  vim.keymap.set("n", "<leader>fs", function()
    local pickers, finders, conf, previewers, actions, action_state =
      require("telescope.pickers"),
      require("telescope.finders"),
      require("telescope.config").values,
      require("telescope.previewers"),
      require("telescope.actions"),
      require("telescope.actions.state")

    local file_path = vim.fn.expand("%:p")
    local handle = io.popen("rg --no-heading --line-number --column SEC: " .. file_path)
    local results = {}

    if handle then
      for line in handle:lines() do
        local lnum, col, text = line:match("(%d+):(%d+):(.*)")
        if lnum and text then
          table.insert(results, {
            display = text,
            ordinal = text,
            filename = file_path,
            lnum = tonumber(lnum),
            col = tonumber(col),
          })
        end
      end
      handle:close()
    end

    table.sort(results, function(a, b)
      return a.lnum > b.lnum
    end)

    pickers
      .new({}, {
        prompt_title = "Sections in Current File",
        finder = finders.new_table({
          results = results,
          entry_maker = function(entry)
            return entry
          end,
        }),
        sorter = conf.generic_sorter({}),
        previewer = previewers.vim_buffer_vimgrep.new({}),
        attach_mappings = function(_, map)
          map("i", "<CR>", function(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            vim.cmd("edit " .. selection.filename)
            vim.api.nvim_win_set_cursor(0, { selection.lnum, selection.col })
          end)
          return true
        end,
      })
      :find()
  end, { desc = "Find Sections in current file" })
  vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Show keymaps" })
  vim.keymap.set("n", "<leader>/", function()
    builtin.current_buffer_fuzzy_find({
      layout_config = {
        preview_width = 0,
      },
    })
  end, { desc = "Fuzzy find in current buffer" })
  vim.keymap.set("n", "<leader>fo", function()
    builtin.live_grep({
      grep_open_files = true,
      prompt_title = "Live Grep in Open Files",
    })
  end, { desc = "Fuzzy find open files" })
  vim.keymap.set("n", "<leader>fn", function()
    builtin.find_files({
      cwd = vim.fn.stdpath("config"),
    })
  end, { desc = "Fuzzy find Neovim files" })
end

M.auto_session = function()
  vim.keymap.set("n", "<leader>ws", "<cmd>SessionSave<CR>", { desc = "Save session for root dir" })
  vim.keymap.set("n", "<leader>wr", "<cmd>SessionRestore<CR>", { desc = "Restore session for cwd" })
end

M.treesitter = {
  init_selection = "<leader>]",
  node_incremental = "<leader>]",
  scope_incremental = false,
  node_decremental = "<leader>[",
}

M.todo_comments = function()
  local todo_comments = require("todo-comments")
  vim.keymap.set("n", "]t", function()
    todo_comments.jump_next()
  end, { desc = "Next todo comment" })
  vim.keymap.set("n", "[t", function()
    todo_comments.jump_prev()
  end, { desc = "Previous todo comment" })
  vim.keymap.set("n", "]c", function()
    todo_comments.jump_next({ keywords = { "SEC" } })
  end, { desc = "Next Section" })
  vim.keymap.set("n", "[c", function()
    todo_comments.jump_prev({ keywords = { "SEC" } })
  end, { desc = "Previous Section" })
end

M.substitute = function()
  local substitute = require("substitute")
  vim.keymap.set("n", "s", substitute.operator, { desc = "Substitute with motion" })
  vim.keymap.set("n", "ss", substitute.line, { desc = "Substitute line" })
  vim.keymap.set("n", "S", substitute.eol, { desc = "Substitute to end of line" })
  vim.keymap.set("x", "s", substitute.visual, { desc = "Substitute in visual mode" })
end

M.surround = {
  insert = "<C-g>s",
  insert_line = "<C-g>S",
  normal = "ys",
  normal_cur = "yss",
  normal_line = "yS",
  normal_cur_line = "ySS",
  visual = "S",
  visual_line = "gS",
  delete = "ds",
  change = "cs",
  change_line = "cS",
}
-- surround:
-- ys + motion + symbol: add surrounding
-- ds + symbol: delete surrounding
-- cs + ori_symbol + new_symbol: change symbol
-- symbol: ', ", (, [, {, t, f
--                        (t=tag, f=function)

M.trouble = {
  { "<leader>xx", ":Trouble diagnostics toggle<CR>", desc = "Open trouble workspace diagnostics" },
  { "<leader>xw", ":Trouble diagnostics toggle<CR>", desc = "Open trouble workspace diagnostics" },
  { "<leader>xd", ":Trouble diagnostics toggle filter.buf=0<CR>", desc = "Open trouble document diagnostics" },
  { "<leader>xq", ":Trouble quickfix toggle<CR>", desc = "Open trouble quickfix list" },
  { "<leader>xl", ":Trouble loclist toggle<CR>", desc = "Open trouble location list" },
  { "<leader>xt", ":Trouble todo toggle<CR>", desc = "Open todos in trouble" },
}

M.gitsigns = function(bufnr)
  local gs = package.loaded.gitsigns

  local function map(mode, l, r, desc)
    vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
  end

  -- Navigation
  map("n", "]h", gs.next_hunk, "Next Hunk")
  map("n", "[h", gs.prev_hunk, "Prev Hunk")

  -- Actions
  map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
  map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
  map("v", "<leader>hs", function()
    gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
  end, "Stage hunk")
  map("v", "<leader>hr", function()
    gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
  end, "Reset hunk")

  map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
  map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")

  map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")

  map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")

  map("n", "<leader>hb", function()
    gs.blame_line({ full = true })
  end, "Blame line")
  map("n", "<leader>hB", gs.toggle_current_line_blame, "Toggle line blame")

  map("n", "<leader>hd", gs.diffthis, "Diff this")
  map("n", "<leader>hD", function()
    gs.diffthis("~")
  end, "Diff this ~")

  map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Gitsigns select hunk")
end

M.lazygit = {
  { "<leader>lg", ":LazyGit<cr>", desc = "Open lazy git" },
}

M.undotree = function()
  local clearTheUndoTree = function()
    local file_path = vim.fn.expand("%:p")
    if file_path == "" then
      vim.notify("No file associated with the current buffer.", vim.log.levels.WARN)
      return
    end

    local to_be_delete_file = file_path:gsub("/", "%%")
    local undodir = vim.fn.stdpath("data") .. "/undo"
    local undo_file_path = undodir .. "/" .. to_be_delete_file

    if vim.fn.filereadable(undo_file_path) == 1 then
      vim.fn.delete(undo_file_path)
      vim.notify("Undo file for " .. file_path .. " has been cleared.", vim.log.levels.INFO)
    else
      vim.notify("No undo file found for " .. file_path, vim.log.levels.WARN)
    end
  end
  local undotree = require("undotree")
  vim.keymap.set("n", "<leader>uu", undotree.toggle, { desc = "Open undo tree" })
  vim.keymap.set("n", "<leader>uc", clearTheUndoTree, { desc = "Clear Undotree of current file" })
end

M.treesj = function()
  local treesj = require("treesj")
  vim.keymap.set("n", "<leader>mm", treesj.toggle, { desc = "Split/Join blocks of code" })
end

M.noice = function()
  -- Default command line keymaps:
  -- <Tab><C-n>, <S-Tab><C-p> Navigate options
  -- <C-e> Close completion panel
  -- <C-u> Clear command now typing
  -- <C-w> Delete a word
  vim.keymap.set("n", "<leader>nn", ":Noice<CR>", { desc = "Open Noice UI" })
  vim.keymap.set("n", "<leader>na", ":NoiceAll<CR>", { desc = "Open Noice UI (All)" })
  vim.keymap.set("n", "<leader>nd", ":NoiceDismiss<CR>", { desc = "Dismiss Noice Notices" })
  vim.keymap.set("n", "<leader>nl", ":NoiceLast<CR>", { desc = "Check Last Notice" })
  vim.keymap.set("n", "<leader>nt", ":NoiceTelescope<CR>", { desc = "Open Noice Telescope" })
end

M.outline = function()
  vim.keymap.set("n", "<leader>k", ":Outline<CR>", { desc = "Toggle Outline", silent = true })
end

M.outline_table = {
  show_help = "?",
  close = { "<Esc>", "q" },
  -- Jump to symbol under cursor.
  -- It can auto close the outline window when triggered, see
  -- 'auto_close' option above.
  goto_location = "<Cr>",
  -- Jump to symbol under cursor but keep focus on outline window.
  peek_location = "o",
  -- Visit location in code and close outline immediately
  goto_and_close = "<S-Cr>",
  -- Change cursor position of outline window to match current location in code.
  -- 'Opposite' of goto/peek_location.
  restore_location = "<C-g>",
  -- Open LSP/provider-dependent symbol hover information
  hover_symbol = "<C-space>",
  -- Preview location code of the symbol under cursor
  toggle_preview = "K",
  rename_symbol = "r",
  code_actions = "a",
  -- These fold actions are collapsing tree nodes, not code folding
  fold = "h",
  unfold = "l",
  fold_toggle = "<Tab>",
  -- Toggle folds for all nodes.
  -- If at least one node is folded, this action will fold all nodes.
  -- If all nodes are folded, this action will unfold all nodes.
  fold_toggle_all = "<S-Tab>",
  fold_all = "W",
  unfold_all = "E",
  fold_reset = "R",
  -- Move down/up by one line and peek_location immediately.
  -- You can also use outline_window.auto_jump=true to do this for any
  -- j/k/<down>/<up>.
  down_and_jump = "<C-j>",
  up_and_jump = "<C-k>",
}

M.table = { -- next and prev work in Normal and Insert mode. All other mappings work in Normal mode.
  next = "<TAB>", -- Go to next cell.
  prev = "<S-TAB>", -- Go to previous cell.
  insert_row_up = "<A-k>", -- Insert a row above the current row.
  insert_row_down = "<A-j>", -- Insert a row below the current row.
  move_row_up = "<A-S-k>", -- Move the current row up.
  move_row_down = "<A-S-j>", -- Move the current row down.
  insert_column_left = "<A-h>", -- Insert a column to the left of current column.
  insert_column_right = "<A-l>", -- Insert a column to the right of current column.
  move_column_left = "<A-S-h>", -- Move the current column to the left.
  move_column_right = "<A-S-l>", -- Move the current column to the right.
  insert_table = "<A-t>", -- Insert a new table.
  insert_table_alt = "<A-S-t>", -- Insert a new table that is not surrounded by pipes.
  delete_column = "<A-d>", -- Delete the column under cursor.
}

M.markdown_preview = {
  { "<leader>mp", ":MarkdownPreview<CR>", desc = "Open Markdown Preview" },
  { "<leader>ms", ":MarkdownPreviewStop<CR>", desc = "Stop Markdown Preview" },
  { "<leader>mt", ":MarkdownPreviewToggle<CR>", desc = "Toggle Markdown Preview" },
}

M.obsidian = function()
  vim.keymap.set("n", "<leader>of", ":ObsidianQuickSwitch<CR>", { desc = "Find files in vault", silent = true })
  vim.keymap.set("n", "<leader>og", ":ObsidianSearch<CR>", { desc = "Grep string in vault", silent = true })
  vim.keymap.set("n", "<leader>oo", ":ObsidianOpen<CR>", { desc = "Open current file in Obsidian", silent = true })
  vim.keymap.set("n", "<leader>on", ":ObsidianNewFromTemplate<CR>", { desc = "Create New Note (Obsidian)", silent = true })
  vim.keymap.set("n", "<leader>ob", ":ObsidianBacklinks<CR>", { desc = "Check backlinks to this file", silent = true })
  vim.keymap.set("n", "<leader>ot", ":ObsidianTemplate<CR>", { desc = "Insert a template", silent = true })
  vim.keymap.set("n", "<leader>or", ":ObsidianRenameID<CR>", { desc = "Rename Obsidian Note", silent = true })
end

M.obsidian_table = function()
  local obsidian = require("obsidian")
  local function gf_link_in_line(isGF)
    -- INFO: If it's foldable, toggle fold. Else try toggle link.
    local line = vim.api.nvim_get_current_line()
    if not isGF and string.match(line, "^#+%s.*$") then
      vim.schedule(function() -- ∵ `normal!` cannot be used in `opts = { expr = true }`
        vim.cmd("normal! za")
        vim.cmd("normal! zz")
      end)
      return ""
    end

    -- try Wiki Link: [[...]]
    local link_start, _ = line:find("%[%[.-%]%]") -- _ = link_end
    if link_start then
      local target_col = link_start + 2
      vim.api.nvim_win_set_cursor(0, { vim.fn.line("."), target_col - 1 }) -- column: 0-indexed
      vim.cmd("ObsidianFollowLink")
      return ""
    end

    -- try Markdown Link: [text](target)
    local md_link_start, _ = line:find("%[.-%]%((.-)%)") -- _ = md_link_end
    if md_link_start then
      local paren_index = line:find("%(", md_link_start) -- move cursor to '('
      if paren_index then
        vim.api.nvim_win_set_cursor(0, { vim.fn.line("."), paren_index })
        vim.cmd("ObsidianFollowLink")
        return ""
      end
    end

    -- try angle bracket URL: <https://www.google.com>
    local angle_start, _ = line:find("<https?://[^>]+>") --  _ = angle_end
    if angle_start then
      local target_col = angle_start + 1
      vim.api.nvim_win_set_cursor(0, { vim.fn.line("."), target_col - 1 })
      vim.cmd("ObsidianFollowLink")
      return ""
    end

    return obsidian.util.gf_passthrough()
  end

  return {
    -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
    ["gf"] = {
      action = function()
        return gf_link_in_line(true)
      end,
      opts = { noremap = false, expr = true, buffer = true },
    },
    ["<CR>"] = {
      action = function()
        return gf_link_in_line(false)
      end,
      opts = { expr = true, buffer = true },
    },
    ["<leader>oc"] = { -- Toggle check-boxes.
      action = function()
        return obsidian.util.toggle_checkbox()
      end,
      opts = { desc = "Toggle check-boxes", buffer = true },
    },
    -- -- Smart action depending on context, either follow link or toggle checkbox.
    -- ["<cr>"] = {
    --   action = function() return obsidian.util.smart_action() end,
    --   opts = { buffer = true, expr = true },
    -- },
  }
end

M.flutter = function()
  vim.keymap.set("n", "<leader>fF", ":Telescope flutter commands<CR>", { desc = "Flutter tools commands", silent = true })
end

M.img_clip = {
  { "<leader>i", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
}

return M
