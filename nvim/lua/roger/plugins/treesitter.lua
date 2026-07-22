return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    local ts = require("nvim-treesitter")
    require("nvim-ts-autotag").setup()

    -- set of parsers the plugin knows how to install
    local available = {}
    for _, lang in ipairs(ts.get_available()) do
      available[lang] = true
    end
    -- set of parsers already on disk (kept in sync as we install more)
    local installed = {}
    for _, lang in ipairs(ts.get_installed("parsers")) do
      installed[lang] = true
    end

    local function activate(buf, lang)
      installed[lang] = true
      pcall(vim.treesitter.start, buf, lang) -- Neovim-native highlighting
    end

    -- highlight on open; auto-install the parser first if we don't have it yet
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("roger_treesitter", { clear = true }),
      callback = function(ev)
        local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
        if not available[lang] then
          return
        end
        if installed[lang] then
          activate(ev.buf, lang)
        else
          ts.install({ lang }):await(vim.schedule_wrap(function(err)
            if not err then
              activate(ev.buf, lang)
            end
          end))
        end
      end,
    })
  end,
}
