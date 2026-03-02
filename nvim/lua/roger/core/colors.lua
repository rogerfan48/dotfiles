-- Vim number and Vim relativenumber
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#7adff0", bold = true })
    vim.api.nvim_set_hl(0, "LineNr", { fg = "#4d5c6e" })
    vim.api.nvim_set_hl(0, "CursorLine", { bg = "#303040" })

    -- ========================================
    -- Vim 內建 Highlight Groups（統一設定）
    -- ========================================
    -- 這些是 Vim/Neovim 內建的 highlight groups，很多 Treesitter 會 link 到這些
    vim.api.nvim_set_hl(0, "Constant", { link = "@constant" })        -- 常數
    vim.api.nvim_set_hl(0, "String", { link = "@string" })             -- 字串
    vim.api.nvim_set_hl(0, "Character", { link = "@character" })       -- 字元
    vim.api.nvim_set_hl(0, "Number", { link = "@number" })             -- 數字
    vim.api.nvim_set_hl(0, "Boolean", { link = "@boolean" })           -- 布林值
    vim.api.nvim_set_hl(0, "Float", { link = "@number.float" })        -- 浮點數

    vim.api.nvim_set_hl(0, "Identifier", { link = "@variable" })       -- 識別符
    vim.api.nvim_set_hl(0, "Function", { link = "@function" })         -- 函數

    vim.api.nvim_set_hl(0, "Statement", { link = "@keyword" })         -- 語句
    vim.api.nvim_set_hl(0, "Conditional", { link = "@keyword.conditional" }) -- if/else
    vim.api.nvim_set_hl(0, "Repeat", { link = "@keyword.repeat" })     -- for/while
    vim.api.nvim_set_hl(0, "Label", { link = "@label" })               -- 標籤
    vim.api.nvim_set_hl(0, "Operator", { link = "@operator" })         -- 運算符
    vim.api.nvim_set_hl(0, "Keyword", { link = "@keyword" })           -- 關鍵字
    vim.api.nvim_set_hl(0, "Exception", { link = "@keyword.exception" }) -- try/catch

    vim.api.nvim_set_hl(0, "PreProc", { link = "@keyword.directive" })    -- #include, #define (前處理器) -> 青色
    vim.api.nvim_set_hl(0, "Include", { link = "@keyword.directive" })   -- #include -> 青色
    vim.api.nvim_set_hl(0, "Define", { link = "@keyword.directive" })    -- #define -> 青色
    vim.api.nvim_set_hl(0, "Macro", { link = "@constant" })              -- 巨集名稱 -> 紅色
    vim.api.nvim_set_hl(0, "PreCondit", { link = "@keyword.directive" }) -- #if, #ifdef -> 青色

    vim.api.nvim_set_hl(0, "Type", { link = "@type" })                    -- 型別
    vim.api.nvim_set_hl(0, "StorageClass", { link = "@keyword.modifier" }) -- public, private, static, const -> 紫色
    vim.api.nvim_set_hl(0, "Structure", { link = "@type" })               -- struct, union
    vim.api.nvim_set_hl(0, "Typedef", { link = "@type.definition" })      -- typedef

    vim.api.nvim_set_hl(0, "Special", { link = "@punctuation.special" }) -- 特殊符號
    vim.api.nvim_set_hl(0, "SpecialChar", { link = "@string.escape" }) -- 跳脫字元
    vim.api.nvim_set_hl(0, "Tag", { link = "@tag" })                   -- HTML tag
    vim.api.nvim_set_hl(0, "Delimiter", { link = "@punctuation.delimiter" }) -- 分隔符
    vim.api.nvim_set_hl(0, "SpecialComment", { link = "@comment.documentation" }) -- 特殊註解
    vim.api.nvim_set_hl(0, "Debug", { link = "@keyword" })             -- debug 關鍵字

    vim.api.nvim_set_hl(0, "Comment", { link = "@comment" })           -- 註解

    -- ========================================
    -- Material Theme Dark Modern 配色
    -- ========================================

    -- 🔹 關鍵字 (Keywords) - 青色/紫色
    vim.api.nvim_set_hl(0, "@keyword", { fg = "#89DDFF" })                -- for, while, if, return, import
    vim.api.nvim_set_hl(0, "@keyword.function", { fg = "#C792EA" })       -- def, function
    vim.api.nvim_set_hl(0, "@keyword.type", { fg = "#C792EA" })           -- class, struct, enum
    vim.api.nvim_set_hl(0, "@keyword.modifier", { fg = "#C792EA" })       -- public, private, protected, static
    vim.api.nvim_set_hl(0, "@keyword.return", { fg = "#89DDFF" })         -- return
    vim.api.nvim_set_hl(0, "@keyword.operator", { fg = "#89DDFF" })       -- and, or, in, is
    vim.api.nvim_set_hl(0, "@keyword.import", { fg = "#89DDFF" })         -- import, from
    vim.api.nvim_set_hl(0, "@keyword.import.cpp", { fg = "#89DDFF" })     -- include
    vim.api.nvim_set_hl(0, "@keyword.directive", { fg = "#89DDFF" })      -- #include, #define, #pragma
    vim.api.nvim_set_hl(0, "@keyword.repeat", { fg = "#89DDFF" })         -- for, while
    vim.api.nvim_set_hl(0, "@keyword.conditional", { fg = "#89DDFF" })    -- if, else, elif
    vim.api.nvim_set_hl(0, "@keyword.exception", { fg = "#89DDFF" })      -- try, except, raise

    -- 🔹 變數 (Variables) - 淡青白色
    vim.api.nvim_set_hl(0, "@variable", { fg = "#EEFFFF" })               -- 一般變數
    vim.api.nvim_set_hl(0, "@variable.builtin", { fg = "#FF5370" })       -- self, this, super
    vim.api.nvim_set_hl(0, "@variable.parameter", { fg = "#F78C6C" })     -- 函數參數
    vim.api.nvim_set_hl(0, "@variable.member", { fg = "#EEFFFF" })        -- object.property

    -- 🔹 函數 (Functions) - 藍色
    vim.api.nvim_set_hl(0, "@function", { fg = "#82AAFF" })               -- 函數名稱
    vim.api.nvim_set_hl(0, "@function.builtin", { fg = "#82AAFF" })       -- print, len, map
    vim.api.nvim_set_hl(0, "@function.call", { fg = "#82AAFF" })          -- 函數呼叫
    vim.api.nvim_set_hl(0, "@function.method", { fg = "#82AAFF" })        -- 方法
    vim.api.nvim_set_hl(0, "@function.method.call", { fg = "#82AAFF" })   -- 方法呼叫
    vim.api.nvim_set_hl(0, "@constructor", { fg = "#FFCB6B" })            -- 建構函數
    vim.api.nvim_set_hl(0, "@constructor.python", { fg = "#FFCB6B" })     -- Python 類別實例化

    -- 🔹 型別 (Types) - 黃色
    vim.api.nvim_set_hl(0, "@type", { fg = "#FFCB6B" })                   -- 類別名稱、型別
    vim.api.nvim_set_hl(0, "@type.builtin", { fg = "#C792EA" })           -- int, str, bool, void
    vim.api.nvim_set_hl(0, "@type.definition", { fg = "#FFCB6B" })        -- 型別定義
    vim.api.nvim_set_hl(0, "@type.qualifier", { fg = "#C792EA" })         -- const, volatile, restrict
    vim.api.nvim_set_hl(0, "@attribute", { fg = "#C792EA" })              -- 裝飾器 @decorator

    -- 🔹 字串 (Strings) - 淺綠色
    vim.api.nvim_set_hl(0, "@string", { fg = "#C3E88D" })                 -- 字串
    vim.api.nvim_set_hl(0, "@string.escape", { fg = "#89DDFF" })          -- 跳脫字元 \n
    vim.api.nvim_set_hl(0, "@string.special", { fg = "#89DDFF" })         -- 特殊字串
    vim.api.nvim_set_hl(0, "@string.regexp", { fg = "#89DDFF" })          -- 正規表達式
    vim.api.nvim_set_hl(0, "@character", { fg = "#C3E88D" })              -- 單一字元

    -- 🔹 數字與常數 (Numbers & Constants) - 橘紅色
    vim.api.nvim_set_hl(0, "@number", { fg = "#F78C6C" })                 -- 數字
    vim.api.nvim_set_hl(0, "@number.float", { fg = "#F78C6C" })           -- 浮點數
    vim.api.nvim_set_hl(0, "@boolean", { fg = "#F78C6C" })                -- true/false
    vim.api.nvim_set_hl(0, "@constant", { fg = "#F07178" })               -- 常數
    vim.api.nvim_set_hl(0, "@constant.builtin", { fg = "#F78C6C" })       -- True, False, None

    -- 🔹 運算符與標點 (Operators) - 青色
    vim.api.nvim_set_hl(0, "@operator", { fg = "#89DDFF" })               -- +, -, *, /, =
    vim.api.nvim_set_hl(0, "@punctuation.delimiter", { fg = "#89DDFF" })  -- , ; :
    vim.api.nvim_set_hl(0, "@punctuation.bracket", { fg = "#cfd4ff" })    -- ( ) [ ] { }

    -- 🔹 屬性與欄位 (Properties)
    vim.api.nvim_set_hl(0, "@property", { fg = "#cfd4ff" })               -- 物件屬性
    vim.api.nvim_set_hl(0, "@field", { fg = "#cfd4ff" })                  -- struct 欄位

    -- 🔹 註解 (Comments) - 灰藍色
    vim.api.nvim_set_hl(0, "@comment", { fg = "#546E7A", italic = true }) -- 註解

    -- 🔹 標籤與模組 (Tags & Modules)
    vim.api.nvim_set_hl(0, "@tag", { fg = "#F07178" })                    -- HTML 標籤
    vim.api.nvim_set_hl(0, "@tag.attribute", { fg = "#C792EA" })          -- 標籤屬性
    vim.api.nvim_set_hl(0, "@tag.delimiter", { fg = "#89DDFF" })          -- < >
    vim.api.nvim_set_hl(0, "@namespace", { fg = "#FFCB6B" })              -- namespace
    vim.api.nvim_set_hl(0, "@module", { fg = "#FFCB6B" })                 -- 模組名稱
    vim.api.nvim_set_hl(0, "@label", { fg = "#89DDFF" })                  -- 標籤 (goto label)

    -- 🔹 特殊語義 (Semantic - LSP Types)
    -- LSP 會自動 link 到對應的 Treesitter groups，除非有特殊需求才覆蓋
    vim.api.nvim_set_hl(0, "@lsp.type.class", { link = "@type" })              -- 類別 → 黃色
    vim.api.nvim_set_hl(0, "@lsp.type.function", { link = "@function" })       -- 函數 → 藍色
    vim.api.nvim_set_hl(0, "@lsp.type.method", { link = "@function.method" })  -- 方法 → 藍色
    vim.api.nvim_set_hl(0, "@lsp.type.variable", { link = "@variable" })       -- 變數 → 白色
    vim.api.nvim_set_hl(0, "@lsp.type.parameter", { link = "@variable.parameter" }) -- 參數 → 橘色
    vim.api.nvim_set_hl(0, "@lsp.type.property", { link = "@property" })       -- 屬性 → 白色
    vim.api.nvim_set_hl(0, "@lsp.type.enumMember", { link = "@constant" })     -- enum 成員 → 紅色

    -- 這些是 LSP 特有的，沒有對應的 Treesitter groups，所以直接設定顏色
    vim.api.nvim_set_hl(0, "@lsp.type.module", { link = "@type" })         -- 模組 (nn, transforms, models) -> 黃色
    vim.api.nvim_set_hl(0, "@lsp.type.namespace", { link = "@type" })      -- namespace -> 黃色
    vim.api.nvim_set_hl(0, "@lsp.type.macro", { link = "@type.builtin" })  -- 巨集（clangd 會誤把 int 等識別為 macro）-> 紫色
    vim.api.nvim_set_hl(0, "@lsp.type.decorator", { link = "@attribute" }) -- 裝飾器 -> 黃色
    vim.api.nvim_set_hl(0, "@lsp.type.keyword", { link = "@keyword" })     -- 關鍵字（有些 LSP 會提供）-> 青色

    -- 🔹 LSP Modifiers（修飾符）
    vim.api.nvim_set_hl(0, "@lsp.mod.readonly", { link = "@constant" })                  -- 常數（readonly 變數）
    vim.api.nvim_set_hl(0, "@lsp.mod.defaultLibrary", { link = "@type" })                -- 標準庫
    vim.api.nvim_set_hl(0, "@lsp.mod.builtin", { fg = "#89DDFF" })                       -- 內建
    vim.api.nvim_set_hl(0, "@lsp.mod.globalScope", {})                                   -- 全域範圍（不改變顏色）
    vim.api.nvim_set_hl(0, "@lsp.mod.static", {})                                        -- static（不改變顏色）
    vim.api.nvim_set_hl(0, "@lsp.mod.declaration", {})                                   -- 宣告（不改變顏色）

    -- 🔹 LSP Type + Modifier 組合（優先級最高）
    vim.api.nvim_set_hl(0, "@lsp.typemod.variable.readonly", { link = "@constant" })          -- 常數變數 -> 紅色
    vim.api.nvim_set_hl(0, "@lsp.typemod.variable.defaultLibrary", { link = "@variable" })    -- 標準庫變數 -> 白色
    vim.api.nvim_set_hl(0, "@lsp.typemod.function.defaultLibrary", { link = "@function" })    -- 標準庫函數 -> 藍色
    vim.api.nvim_set_hl(0, "@lsp.typemod.method.defaultLibrary", { link = "@function" })      -- 標準庫方法 -> 藍色
    vim.api.nvim_set_hl(0, "@lsp.typemod.class.defaultLibrary", { link = "@type" })           -- 標準庫類別 -> 黃色
    vim.api.nvim_set_hl(0, "@lsp.typemod.macro.globalScope", { link = "@type.builtin" })      -- 全域巨集（clangd 會把 int/void 等誤判為此）-> 紫色
    vim.api.nvim_set_hl(0, "@lsp.typemod.variable.globalScope", {})                           -- 全域變數（不額外改變顏色）
    vim.api.nvim_set_hl(0, "@lsp.typemod.function.globalScope", {})                           -- 全域函數（不額外改變顏色）

    local hl = vim.api.nvim_get_hl(0, { name = "rainbow1", link = false })
    hl.bold = true
    vim.api.nvim_set_hl(0, "@markup.heading.1.markdown", hl)
    hl = vim.api.nvim_get_hl(0, { name = "rainbow2", link = false })
    hl.bold = true
    vim.api.nvim_set_hl(0, "@markup.heading.2.markdown", hl)
    hl = vim.api.nvim_get_hl(0, { name = "rainbow3", link = false })
    hl.bold = true
    vim.api.nvim_set_hl(0, "@markup.heading.3.markdown", hl)
    hl = vim.api.nvim_get_hl(0, { name = "rainbow4", link = false })
    hl.bold = true
    vim.api.nvim_set_hl(0, "@markup.heading.4.markdown", hl)
    hl = vim.api.nvim_get_hl(0, { name = "rainbow5", link = false })
    hl.bold = true
    vim.api.nvim_set_hl(0, "@markup.heading.5.markdown", hl)
    hl = vim.api.nvim_get_hl(0, { name = "rainbow6", link = false })
    hl.bold = true
    vim.api.nvim_set_hl(0, "@markup.heading.6.markdown", hl)

    hl = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
    vim.api.nvim_set_hl(0, "@markup.quote", hl)
    hl = vim.api.nvim_get_hl(0, { name = "@markup.strong", link = false })
    hl.fg = "#c9a885"
    vim.api.nvim_set_hl(0, "@markup.strong", hl)
    hl = vim.api.nvim_get_hl(0, { name = "@markup.italic", link = false })
    hl.fg = "#c79cd6"
    vim.api.nvim_set_hl(0, "@markup.italic", hl)
    hl = vim.api.nvim_get_hl(0, { name = "RenderMarkdownCode", link = false })
    hl.bg = "#2d2d2d"
    vim.api.nvim_set_hl(0, "RenderMarkdownCode", hl)
    hl = vim.api.nvim_get_hl(0, { name = "@markup.link.label", link = false })
    -- hl.underdashed = true
    hl.underdouble = true
    hl.fg = "#89dceb"
    vim.api.nvim_set_hl(0, "@markup.link.label", hl)
    vim.api.nvim_set_hl(0, "RenderMarkdownExternalLinkIcon", { fg = "#f590eb" })
    hl = vim.api.nvim_get_hl(0, { name = "RenderMarkdownBullet", link = false })
    hl.fg = "#b0ccd4"
    vim.api.nvim_set_hl(0, "RenderMarkdownBullet", hl)

    hl = vim.api.nvim_get_hl(0, { name = "OutlineCurrent", link = false })
    hl.bg = "#265473"
    vim.api.nvim_set_hl(0, "OutlineCurrent", hl)

    vim.api.nvim_set_hl(0, "FlutterClosingTag", { fg = "#484848" })

    -- `K` and Leetcode.nvim bg recovery
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
  end,
})
