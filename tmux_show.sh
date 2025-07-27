#!/bin/bash

# ===================================================================
#  Tmux 樣式設定查詢腳本
#  這個腳本會顯示一系列 Tmux session 和 window 樣式選項的目前值。
#  請確保在執行此腳本時，Tmux 伺服器正在運行中。
# ===================================================================

# 檢查 tmux 指令是否存在
if ! command -v tmux &> /dev/null
then
    echo "錯誤：找不到 tmux 指令。請確保 Tmux 已安裝並在您的 PATH 中。"
    exit 1
fi

# 檢查 tmux 伺服器是否正在運行
if ! tmux info &> /dev/null
then
    echo "提示：Tmux 伺服器目前沒有在運行。將顯示預設值。"
    # 如果沒有伺服器，指令仍然可以顯示預設值，所以腳本可以繼續
fi

echo "--- 查詢 Session 層級的樣式選項 ---"
tmux show-options -g display-panes-active-colour
tmux show-options -g display-panes-colour
tmux show-options -g message-style
tmux show-options -g status-left-length
tmux show-options -g status-left-style
tmux show-options -g status-left
tmux show-options -g status-right-length
tmux show-options -g status-right-style
tmux show-options -g status-right
tmux show-options -g status-style
echo "" #
echo "--- 查詢 Window 層級的樣式選項 ---"
tmux show-window-options -g mode-style
tmux show-window-options -g pane-active-border-style
tmux show-window-options -g pane-border-format
tmux show-window-options -g pane-border-style
tmux show-window-options -g window-active-style
tmux show-window-options -g window-status-current-format
tmux show-window-options -g window-status-current-style
tmux show-window-options -g window-status-format
tmux show-window-options -g window-status-separator
tmux show-window-options -g window-status-style
tmux show-window-options -g window-style

echo ""
echo "--- 查詢完畢 ---"
