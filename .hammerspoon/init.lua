-- 定義熱鍵組合
local hyper = {"alt"}
local toggleKey = "space"

-- 定義 WezTerm 的應用名稱
local weztermAppName = "WezTerm"

-- 熱鍵行為：Alt+Space 切換 WezTerm 顯示/隱藏
-- 不使用 "All Desktops"（macOS Sequoia bug 會導致視窗卡在最上層）
-- 改用 hs.spaces 將 WezTerm 移到當前 Space，效果相同且無 bug
hs.hotkey.bind(hyper, toggleKey, function()
    local app = hs.application.get(weztermAppName)
    if app then
        if app:isFrontmost() then
            app:hide()
        else
            local mainWindow = app:mainWindow()
            if mainWindow then
                -- 移動 WezTerm 到當前 Space 並聚焦
                local currentSpace = hs.spaces.focusedSpace()
                hs.spaces.moveWindowToSpace(mainWindow, currentSpace)
                app:unhide()
                mainWindow:unminimize()
                mainWindow:focus()
            else
                hs.application.launchOrFocus(weztermAppName)
            end
        end
    else
        hs.application.launchOrFocus(weztermAppName)
    end
end)
