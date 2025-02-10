local keymaps = require("roger.core.keymaps")

return {
  "iamcco/markdown-preview.nvim",
  build = "cd app && npm install", -- Install dependencies
  ft = { "markdown" }, -- Load only for markdown files
  cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
  init = function()
    vim.g.mkdp_auto_start = 0 -- Do not auto-start the preview
    vim.g.mkdp_auto_close = 1 -- Automatically close preview when switching buffers
    vim.g.mkdp_refresh_slow = 0 -- Refresh preview in real-time
    vim.g.mkdp_command_for_global = 0 -- Only enable for markdown buffers
    vim.g.mkdp_open_to_the_world = 0 -- Open preview locally only
    vim.g.mkdp_browser = "" -- Use the default system browser
    vim.g.mkdp_preview_options = {
      mkit = {},
      katex = {},
      uml = {},
      maid = {},
      disable_sync_scroll = 0, -- Enable synchronized scrolling
      sync_scroll_type = "middle", -- Scrolling mode: middle, top, relative
      hide_yaml_meta = 1, -- Hide YAML metadata
      sequence_diagrams = {},
      flowchart_diagrams = {},
      content_editable = false, -- Disable content editing in preview
      disable_filename = 0, -- Show file name in preview
    }
    vim.g.mkdp_markdown_css = vim.fn.expand('~/.dotfiles/nvim/markdown.css') -- Custom CSS for markdown preview
    vim.g.mkdp_highlight_css = "" -- Custom syntax highlight CSS
    vim.g.mkdp_page_title = "「${name}」" -- Set the title of the preview page
  end,
  keys = keymaps.markdown_preview,
}
