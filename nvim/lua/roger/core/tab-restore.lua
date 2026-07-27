-- Chrome-like "reopen closed tab" for nvim tabpages
local M = {}

local pending = {} -- tabpage handle -> snapshot taken as its first window closes
local closed = {} -- stack of snapshots, newest last
local MAX_HISTORY = 10

local function capture(tabpage)
  if not vim.api.nvim_tabpage_is_valid(tabpage) then
    return nil
  end

  local cur_win = vim.api.nvim_tabpage_get_win(tabpage)
  local wins, cur_idx = {}, 1
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)
    -- skip neo-tree / terminals / scratch, keep only real files
    if vim.bo[buf].buftype == "" and name ~= "" and vim.fn.filereadable(name) == 1 then
      table.insert(wins, { file = name, cursor = vim.api.nvim_win_get_cursor(win) })
      if win == cur_win then
        cur_idx = #wins
      end
    end
  end

  if #wins == 0 then
    return nil
  end

  local nr = vim.api.nvim_tabpage_get_number(tabpage)
  return { wins = wins, cur = cur_idx, index = nr, cwd = vim.fn.getcwd(-1, nr) }
end

function M.restore()
  local snap = table.remove(closed)
  if not snap then
    vim.notify("No recently closed tab", vim.log.levels.WARN)
    return
  end

  vim.cmd(math.max(math.min(snap.index, vim.fn.tabpagenr("$") + 1) - 1, 0) .. "tabnew")
  if snap.cwd ~= "" and vim.fn.isdirectory(snap.cwd) == 1 then
    vim.cmd("tcd " .. vim.fn.fnameescape(snap.cwd))
  end

  local created = {}
  for i, w in ipairs(snap.wins) do
    if i > 1 then
      vim.cmd("vsplit")
    end
    vim.cmd("edit " .. vim.fn.fnameescape(w.file))
    pcall(vim.api.nvim_win_set_cursor, 0, w.cursor)
    created[i] = vim.api.nvim_get_current_win()
  end

  if created[snap.cur] and vim.api.nvim_win_is_valid(created[snap.cur]) then
    vim.api.nvim_set_current_win(created[snap.cur])
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup("RogerTabRestore", { clear = true })

  -- WinClosed fires while the window is still in the layout, so the first one
  -- per tab sees the tab fully intact -- that is the state worth keeping
  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    callback = function(args)
      local win = tonumber(args.match)
      if not win or not vim.api.nvim_win_is_valid(win) then
        return
      end
      local tab = vim.api.nvim_win_get_tabpage(win)
      if pending[tab] == nil then
        pending[tab] = capture(tab) or false
      end
      vim.schedule(function()
        -- only a split was closed and the tab lives on: drop the capture
        if vim.api.nvim_tabpage_is_valid(tab) then
          pending[tab] = nil
        end
      end)
    end,
  })

  vim.api.nvim_create_autocmd("TabClosed", {
    group = group,
    callback = function()
      for tab, snap in pairs(pending) do
        if not vim.api.nvim_tabpage_is_valid(tab) then
          pending[tab] = nil
          if snap then
            table.insert(closed, snap)
            if #closed > MAX_HISTORY then
              table.remove(closed, 1)
            end
          end
        end
      end
    end,
  })

  vim.api.nvim_create_user_command("TabRestore", M.restore, { desc = "Reopen the last closed tab" })
end

return M
