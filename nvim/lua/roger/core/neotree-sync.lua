M = {}

--------------------------------------------------------------------------------
-- 判斷指定 tabpage 是否有 Neo-tree 視窗
--------------------------------------------------------------------------------
M.is_neo_tree_open_in_tab = function(tabpage)
  local wins = vim.api.nvim_tabpage_list_wins(tabpage)
  for _, winid in ipairs(wins) do
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
    if ft == "neo-tree" then
      return true
    end
  end
  return false
end

--------------------------------------------------------------------------------
-- 逐個 tab, 開 or 關 Neo-tree
-- 引入一點延遲，避免外部命令切換過快產生衝突
--------------------------------------------------------------------------------
M.toggle_neo_tree_for_all_tabs = function()
  -- 取得所有 tab 的 handle
  local tabpages = vim.api.nvim_list_tabpages()
  -- 取得當前所在的 tab
  local current_tab = vim.api.nvim_get_current_tabpage()

  -- 先檢查「當前 tab」是否開啟了 Neo-tree：如果開啟就表示我們要做「全部關」，否則「全部開」
  local do_close = M.is_neo_tree_open_in_tab(current_tab)

  -- 這裡用「步進式」的方法，一個 tab 執行完再換下一個
  local i = 1
  local function process_next_tab()
    if i > #tabpages then
      -- 全部處理完，最後回到原先所在的 tab
      vim.defer_fn(function()
        vim.api.nvim_set_current_tabpage(current_tab)
      end, 50) -- 加少量延遲確保狀態穩定
      return
    end

    local tp = tabpages[i]
    vim.api.nvim_set_current_tabpage(tp)

    if do_close then
      -- 若當前 tab 有開 Neo-tree，就執行關閉
      --（若這個 tab 其實沒開，:Neotree close 會無事發生，也無妨）
      vim.cmd("Neotree close")
    else
      -- 若要全部開，這裡可使用 show / reveal / focus 等依你需求而定
      vim.cmd("Neotree show")
    end

    i = i + 1
    -- 加一點點延遲（或手動 redraw）再處理下一個 tab，避免切換過快
    vim.defer_fn(process_next_tab, 50) -- 50 毫秒，可自行斟酌增減
  end

  -- 從第一個 tab 開始處理
  process_next_tab()
end

return M
