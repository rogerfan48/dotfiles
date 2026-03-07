-- Vim number and Vim relativenumber
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#7adff0", bold = true })
    vim.api.nvim_set_hl(0, "LineNr", { fg = "#4d5c6e" })
    vim.api.nvim_set_hl(0, "CursorLine", { bg = "#303040" })

    -- ========================================
    -- Material Theme Dark Modern
    -- ========================================
    -- Color palette (single source of truth)
    local c = {
      cyan      = "#89DDFF",
      purple    = "#C792EA",
      blue      = "#82AAFF",
      green     = "#C3E88D",
      yellow    = "#FFCB6B",
      orange    = "#F78C6C",
      red       = "#F07178",
      red_dark  = "#FF5370",
      white     = "#EEFFFF",
      comment   = "#546E7A",
      bracket   = "#cfd4ff",
      property  = "#cfd4ff",
    }

    -- ========================================
    -- Vim Legacy Highlight Groups
    -- ========================================
    -- Set colors directly (no links) so synIDtrans resolves correctly.
    -- Used by files without a treesitter parser (e.g. .zshrc, .tmux.conf)
    vim.api.nvim_set_hl(0, "Comment",      { fg = c.comment, italic = true })
    vim.api.nvim_set_hl(0, "Constant",     { fg = c.red })
    vim.api.nvim_set_hl(0, "String",       { fg = c.green })
    vim.api.nvim_set_hl(0, "Character",    { fg = c.green })
    vim.api.nvim_set_hl(0, "Number",       { fg = c.orange })
    vim.api.nvim_set_hl(0, "Boolean",      { fg = c.orange })
    vim.api.nvim_set_hl(0, "Float",        { fg = c.orange })
    vim.api.nvim_set_hl(0, "Identifier",   { fg = c.white })
    vim.api.nvim_set_hl(0, "Function",     { fg = c.blue })
    vim.api.nvim_set_hl(0, "Statement",    { fg = c.cyan })
    vim.api.nvim_set_hl(0, "Conditional",  { fg = c.cyan })
    vim.api.nvim_set_hl(0, "Repeat",       { fg = c.cyan })
    vim.api.nvim_set_hl(0, "Label",        { fg = c.cyan })
    vim.api.nvim_set_hl(0, "Operator",     { fg = c.cyan })
    vim.api.nvim_set_hl(0, "Keyword",      { fg = c.cyan })
    vim.api.nvim_set_hl(0, "Exception",    { fg = c.cyan })
    vim.api.nvim_set_hl(0, "PreProc",      { fg = c.cyan })
    vim.api.nvim_set_hl(0, "Include",      { fg = c.cyan })
    vim.api.nvim_set_hl(0, "Define",       { fg = c.cyan })
    vim.api.nvim_set_hl(0, "Macro",        { fg = c.red })
    vim.api.nvim_set_hl(0, "PreCondit",    { fg = c.cyan })
    vim.api.nvim_set_hl(0, "Type",         { fg = c.yellow })
    vim.api.nvim_set_hl(0, "StorageClass", { fg = c.purple })
    vim.api.nvim_set_hl(0, "Structure",    { fg = c.yellow })
    vim.api.nvim_set_hl(0, "Typedef",      { fg = c.yellow })
    vim.api.nvim_set_hl(0, "Special",      { fg = c.cyan })
    vim.api.nvim_set_hl(0, "SpecialChar",  { fg = c.cyan })
    vim.api.nvim_set_hl(0, "Tag",          { fg = c.red })
    vim.api.nvim_set_hl(0, "Delimiter",    { fg = c.cyan })
    vim.api.nvim_set_hl(0, "SpecialComment", { fg = c.comment, italic = true })
    vim.api.nvim_set_hl(0, "Debug",        { fg = c.cyan })

    -- ========================================
    -- Treesitter Highlight Groups
    -- ========================================
    -- Keywords
    vim.api.nvim_set_hl(0, "@keyword", { fg = c.cyan })
    vim.api.nvim_set_hl(0, "@keyword.function", { fg = c.purple })        -- def, function
    vim.api.nvim_set_hl(0, "@keyword.type", { fg = c.purple })            -- class, struct, enum
    vim.api.nvim_set_hl(0, "@keyword.modifier", { fg = c.purple })        -- public, private, protected, static
    vim.api.nvim_set_hl(0, "@keyword.return", { fg = c.cyan })
    vim.api.nvim_set_hl(0, "@keyword.operator", { fg = c.cyan })          -- and, or, in, is
    vim.api.nvim_set_hl(0, "@keyword.import", { fg = c.cyan })
    vim.api.nvim_set_hl(0, "@keyword.import.cpp", { fg = c.cyan })
    vim.api.nvim_set_hl(0, "@keyword.directive", { fg = c.cyan })         -- #include, #define, #pragma
    vim.api.nvim_set_hl(0, "@keyword.repeat", { fg = c.cyan })
    vim.api.nvim_set_hl(0, "@keyword.conditional", { fg = c.cyan })
    vim.api.nvim_set_hl(0, "@keyword.exception", { fg = c.cyan })

    -- Variables
    vim.api.nvim_set_hl(0, "@variable", { fg = c.white })
    vim.api.nvim_set_hl(0, "@variable.builtin", { fg = c.red_dark })      -- self, this, super
    vim.api.nvim_set_hl(0, "@variable.parameter", { fg = c.orange })
    vim.api.nvim_set_hl(0, "@variable.member", { fg = c.white })

    -- Functions
    vim.api.nvim_set_hl(0, "@function", { fg = c.blue })
    vim.api.nvim_set_hl(0, "@function.builtin", { fg = c.blue })
    vim.api.nvim_set_hl(0, "@function.call", { fg = c.blue })
    vim.api.nvim_set_hl(0, "@function.method", { fg = c.blue })
    vim.api.nvim_set_hl(0, "@function.method.call", { fg = c.blue })
    vim.api.nvim_set_hl(0, "@constructor", { fg = c.yellow })
    vim.api.nvim_set_hl(0, "@constructor.python", { fg = c.yellow })

    -- Types
    vim.api.nvim_set_hl(0, "@type", { fg = c.yellow })
    vim.api.nvim_set_hl(0, "@type.builtin", { fg = c.purple })            -- int, str, bool, void
    vim.api.nvim_set_hl(0, "@type.definition", { fg = c.yellow })
    vim.api.nvim_set_hl(0, "@type.qualifier", { fg = c.purple })          -- const, volatile, restrict
    vim.api.nvim_set_hl(0, "@attribute", { fg = c.purple })               -- @decorator

    -- Strings
    vim.api.nvim_set_hl(0, "@string", { fg = c.green })
    vim.api.nvim_set_hl(0, "@string.escape", { fg = c.cyan })
    vim.api.nvim_set_hl(0, "@string.special", { fg = c.cyan })
    vim.api.nvim_set_hl(0, "@string.regexp", { fg = c.cyan })
    vim.api.nvim_set_hl(0, "@character", { fg = c.green })

    -- Numbers & Constants
    vim.api.nvim_set_hl(0, "@number", { fg = c.orange })
    vim.api.nvim_set_hl(0, "@number.float", { fg = c.orange })
    vim.api.nvim_set_hl(0, "@boolean", { fg = c.orange })
    vim.api.nvim_set_hl(0, "@constant", { fg = c.red })
    vim.api.nvim_set_hl(0, "@constant.builtin", { fg = c.orange })        -- True, False, None

    -- Operators & Punctuation
    vim.api.nvim_set_hl(0, "@operator", { fg = c.cyan })
    vim.api.nvim_set_hl(0, "@punctuation.delimiter", { fg = c.cyan })
    vim.api.nvim_set_hl(0, "@punctuation.bracket", { fg = c.bracket })

    -- Properties
    vim.api.nvim_set_hl(0, "@property", { fg = c.property })
    vim.api.nvim_set_hl(0, "@field", { fg = c.property })

    -- Comments
    vim.api.nvim_set_hl(0, "@comment", { fg = c.comment, italic = true })

    -- Tags & Modules
    vim.api.nvim_set_hl(0, "@tag", { fg = c.red })
    vim.api.nvim_set_hl(0, "@tag.attribute", { fg = c.purple })
    vim.api.nvim_set_hl(0, "@tag.delimiter", { fg = c.cyan })
    vim.api.nvim_set_hl(0, "@namespace", { fg = c.yellow })
    vim.api.nvim_set_hl(0, "@module", { fg = c.yellow })
    vim.api.nvim_set_hl(0, "@label", { fg = c.cyan })

    -- ========================================
    -- LSP Semantic Tokens
    -- ========================================
    -- LSP types (link to treesitter groups for consistency)
    vim.api.nvim_set_hl(0, "@lsp.type.class", { link = "@type" })
    vim.api.nvim_set_hl(0, "@lsp.type.function", { link = "@function" })
    vim.api.nvim_set_hl(0, "@lsp.type.method", { link = "@function.method" })
    vim.api.nvim_set_hl(0, "@lsp.type.variable", { link = "@variable" })
    vim.api.nvim_set_hl(0, "@lsp.type.parameter", { link = "@variable.parameter" })
    vim.api.nvim_set_hl(0, "@lsp.type.property", { link = "@property" })
    vim.api.nvim_set_hl(0, "@lsp.type.enumMember", { link = "@constant" })
    vim.api.nvim_set_hl(0, "@lsp.type.module", { link = "@type" })
    vim.api.nvim_set_hl(0, "@lsp.type.namespace", { link = "@type" })
    vim.api.nvim_set_hl(0, "@lsp.type.macro", { link = "@type.builtin" })  -- clangd misidentifies int as macro
    vim.api.nvim_set_hl(0, "@lsp.type.decorator", { link = "@attribute" })
    vim.api.nvim_set_hl(0, "@lsp.type.keyword", { link = "@keyword" })

    -- LSP modifiers
    vim.api.nvim_set_hl(0, "@lsp.mod.readonly", { link = "@constant" })
    vim.api.nvim_set_hl(0, "@lsp.mod.defaultLibrary", { link = "@type" })
    vim.api.nvim_set_hl(0, "@lsp.mod.builtin", { fg = c.cyan })
    vim.api.nvim_set_hl(0, "@lsp.mod.globalScope", {})
    vim.api.nvim_set_hl(0, "@lsp.mod.static", {})
    vim.api.nvim_set_hl(0, "@lsp.mod.declaration", {})

    -- LSP type + modifier combos (highest priority)
    vim.api.nvim_set_hl(0, "@lsp.typemod.variable.readonly", { link = "@constant" })
    vim.api.nvim_set_hl(0, "@lsp.typemod.variable.defaultLibrary", { link = "@variable" })
    vim.api.nvim_set_hl(0, "@lsp.typemod.function.defaultLibrary", { link = "@function" })
    vim.api.nvim_set_hl(0, "@lsp.typemod.method.defaultLibrary", { link = "@function" })
    vim.api.nvim_set_hl(0, "@lsp.typemod.class.defaultLibrary", { link = "@type" })
    vim.api.nvim_set_hl(0, "@lsp.typemod.macro.globalScope", { link = "@type.builtin" })  -- clangd int/void
    vim.api.nvim_set_hl(0, "@lsp.typemod.variable.globalScope", {})
    vim.api.nvim_set_hl(0, "@lsp.typemod.function.globalScope", {})

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
