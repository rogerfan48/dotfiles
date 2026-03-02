-- 定義熱鍵組合
local hyper = {"alt"}
local toggleKey = "space"

-- 定義 WezTerm 的應用名稱
local weztermAppName = "WezTerm"

-- 標誌是否已設置為所有桌面顯示
local isWezTermSetToAllDesktops = false

-- 定義一個函數來設置窗口「在所有桌面顯示」
local function setWindowToAllDesktops()
    hs.osascript.applescript([[
        tell application "System Events"
            tell application process "Dock"
                set frontmost to true
                tell UI element "WezTerm" of list 1
                    perform action "AXShowMenu"
                    delay 0.05 -- 最小延遲
                    click menu item "Options" of menu 1
                    click menu item "All Desktops" of menu 1 of menu item "Options" of menu 1
                end tell
            end tell
        end tell
    ]])
    isWezTermSetToAllDesktops = true -- 設置標誌
end

-- macOS Sequoia bug: "All Desktops" 視窗會卡在高層級蓋住其他 App
-- 解法：WezTerm 失焦時直接 hide，hide 後再 show 會重置視窗層級
local appWatcher = hs.application.watcher.new(function(appName, eventType, _app)
    if eventType == hs.application.watcher.deactivated and appName == weztermAppName then
        local weztermApp = hs.application.get(weztermAppName)
        if weztermApp then
            weztermApp:hide()
        end
    end
end)
appWatcher:start()

-- 熱鍵行為
hs.hotkey.bind(hyper, toggleKey, function()
    local app = hs.application.get(weztermAppName)
    if app then
        if app:isFrontmost() then
            -- 如果 WezTerm 被聚焦，隱藏它
            app:hide()
        else
            -- 如果 WezTerm 未被聚焦
            if not isWezTermSetToAllDesktops then
                setWindowToAllDesktops()
            end
            -- 顯示並聚焦（unhide 確保 hide 狀態也能正常還原）
            local mainWindow = app:mainWindow()
            if mainWindow then
                app:unhide()
                mainWindow:unminimize()
                mainWindow:focus()
            else
                hs.application.launchOrFocus(weztermAppName)
            end
        end
    else
        -- 如果 WezTerm 未啟動，啟動它並初始化設置
        hs.application.launchOrFocus(weztermAppName)
        hs.timer.doAfter(1, function()
            if not isWezTermSetToAllDesktops then
                setWindowToAllDesktops()
            end
        end)
    end
end)
