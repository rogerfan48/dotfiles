return {
  "kawre/leetcode.nvim",
  build = ":TSUpdate html",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  arg = "leetcode.nvim",
  opts = {
    lang = "cpp",
    description = {
      width = "50%",
    },
    keys = {
        toggle = { "q" },
        confirm = { "<CR>" },

        reset_testcases = "r",
        use_testcase = "U",
        focus_testcases = "H",
        focus_result = "L",
    },
  },
  config = function(_, opts)
    local keymaps = require("roger.core.keymaps")
    keymaps.leetcode()

    require("leetcode").setup(opts)
    local leetcode_group = vim.api.nvim_create_augroup("LeetCodeSetup", { clear = true })

    vim.api.nvim_create_autocmd('FileType', {
      group = leetcode_group,
      pattern = 'leetcode',
      desc = 'Close Neo-tree when LeetCode opens',
      callback = function()
        pcall(vim.cmd, 'Neotree close')
      end,
      once = true,
    })

    vim.api.nvim_create_autocmd({ 'BufWinEnter', 'FileType' }, {
      group = leetcode_group,
      pattern = '*',
      desc = 'Create a distraction-free environment for LeetCode',
      callback = function()
        if not _G.IS_LEETCODE_SESSION then
          return
        end

        -- 1. Shut down Language Servers and inlay hints
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        for _, client in ipairs(clients) do
          pcall(vim.lsp.stop, client.id)
        end
        pcall(vim.lsp.inlay_hint.enable, false, { bufnr = 0 })

        -- 2. Disable all diagnostics (LSP errors, linter warnings)
        vim.diagnostic.enable(false)

        -- 3. Disable AI assistants
        vim.cmd('Copilot disable')

        -- 4. Disable autocomplete pop-up menu
        vim.bo.omnifunc = ''

        -- 5. Disable spell checking
        vim.opt_local.spell = false

        -- 6. Prevent automatic formatting on save
        vim.b.autoformat = false
      end,
    })
  end,
  plugins = {},
}
