-- Vim number and Vim relativenumber
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#7adff0", bold = true })
    vim.api.nvim_set_hl(0, "LineNr", { fg = "#4d5c6e" })
    vim.api.nvim_set_hl(0, "CursorLine", { bg = "#303040" })

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
  end
})
