local M = {}
local opts = { noremap = true, silent = true }

M.general = function()
  -- using 'jk' as <esc> in INSERT, VISUAL, COMMAND, TERMNIAL are configured in 'better-escape' module
end

M.lsp = function(bufnr)
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
end

M.neo_tree = function()
  local function custom_toggle_neo_tree()
    -- 找到所有 Neo-tree 視窗
    local neo_tree_wins = {}
    for _, win in pairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      local buf_name = vim.api.nvim_buf_get_name(buf)
      if buf_name:match("neo%-tree filesystem") then
        table.insert(neo_tree_wins, win)
      end
    end

    -- 檢查 Neo-tree 狀態
    if #neo_tree_wins > 0 then
      -- Neo-tree 已開啟
      local current_win = vim.api.nvim_get_current_win()
      if vim.tbl_contains(neo_tree_wins, current_win) then
        -- 當前在 Neo-tree 視窗中，關閉它
        vim.cmd("silent Neotree close")
      else
        -- 當前不在 Neo-tree 視窗中，切換到它
        vim.api.nvim_set_current_win(neo_tree_wins[1])
      end
    else
      -- Neo-tree 未開啟，打開它
      vim.cmd("silent Neotree toggle")
    end
  end

  vim.keymap.set('n', '<C-j>', ':Neotree toggle<CR>', {})
  vim.keymap.set('n', '<leader>j', custom_toggle_neo_tree, { desc = "Custom toggle Neo-tree" })
end

M.telescope = function()
  local builtin = require('telescope.builtin')
  vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
  vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
  vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
  vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
end
return M
