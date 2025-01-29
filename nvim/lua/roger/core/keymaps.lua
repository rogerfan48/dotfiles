local M = {}

M.general = function()
  -- using "jk" as <ESC> in INSERT, VISUAL, COMMAND, TERMINAL are configured in "better-escape" module
  vim.keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights", silent = true })

  vim.keymap.set("n", "<leader>ww", ":w<CR>", { desc = "Save file (:w) ", silent = true })
  vim.keymap.set("n", "<leader>q<space>", ":q<CR>", { desc = "Quit current Nvim window (:q)", silent = true })
  vim.keymap.set("n", "<leader>qq", ":qa<CR>", { desc = "Quit all Nvim windows (:qa)", silent = true })

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

  -- increment/decrement numbers
  vim.keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
  vim.keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

  -- window management
  vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
  vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
  vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
  vim.keymap.set("n", "<leader>sx", ":close<CR>", { desc = "Close current split", silent = true })
  vim.keymap.set("n", "<leader>sm", ":MaximizerToggle<CR>", { desc = "Max/min a split", silent = true })

  -- tab management
  vim.keymap.set("n", "<leader>tn", ":tabnew<CR>", { desc = "Open new tab", silent = true })
  vim.keymap.set("n", "<leader>tx", ":tabclose<CR>", { desc = "Close current tab", silent = true })
  vim.keymap.set("n", "<leader>tk", ":tabn<CR>", { desc = "Go to next tab", silent = true })
  vim.keymap.set("n", "<leader>tj", ":tabp<CR>", { desc = "Go to previous tab", silent = true })
  vim.keymap.set("n", "<leader>tp", ":BufferLinePick<CR>", { desc = "Pick tab", silent = true })
  vim.keymap.set("n", "<leader>tf", ":tabnew %<CR>", { desc = "Open current buffer in new tab", silent = true })

  -- from comment.lua
  -- 'gc' + motion.   Ex. gc3j(to 3 lines below), gcG(to EOF), gcc(one line)
end

M.lsp = function()
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if client then
        vim.notify("LSP " .. client.name .. " attached to buffer " .. ev.buf, vim.log.levels.INFO)
      end

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
      vim.keymap.set("n", "[d", vim.diagnostic.goto_next, with_desc("Go to previous diagnostic"))
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
  local function custom_toggle_neo_tree()
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
        vim.cmd("silent Neotree close")
      else
        vim.api.nvim_set_current_win(neo_tree_win)
      end
    else
      vim.cmd("silent Neotree toggle")
    end
  end

  vim.keymap.set("n", "<leader>j", custom_toggle_neo_tree, { desc = "Toggle Neo-tree" })
end

M.telescope = function()
  local builtin = require("telescope.builtin")
  vim.keymap.set(
    "n",
    "<leader>fj",
    ":Telescope find_files hidden=true<CR>",
    { desc = "Fuzzy find files in cwd", silent = true }
  )
  vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Fuzzy find recent files" })
  vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Find string in cwd" })
  vim.keymap.set("n", "<leader>fc", builtin.grep_string, { desc = "Find string under cursor" })
  vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
  vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
  vim.keymap.set("n", "<leader>ft", ":TodoTelescope<cr>", { desc = "Find todos", silent = true })
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
  vim.keymap.set("n", "<leader>m", treesj.toggle, { desc = "Split/Join blocks of code" })
end

return M
