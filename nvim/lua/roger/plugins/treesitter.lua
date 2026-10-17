-- Building parsers needs the tree-sitter CLI and a C compiler; without them only
-- Neovim's bundled parsers work
local can_build = vim.fn.executable("tree-sitter") == 1
  and (vim.fn.executable("cc") == 1 or vim.fn.executable("gcc") == 1 or vim.fn.executable("clang") == 1)

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = can_build and ":TSUpdate" or nil,
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

    -- Always-installed set, incl. injection-only parsers (html-in-markdown) that
    -- the on-demand handler below never installs.
    local ensure_installed = {
      "bash", "c", "cpp", "diff", "gitcommit", "html", "json", "latex", "lua",
      "luadoc", "markdown", "markdown_inline", "python", "query", "regex",
      "toml", "vim", "vimdoc", "yaml",
    }
    local to_install = {}
    for _, lang in ipairs(ensure_installed) do
      if can_build and available[lang] and not installed[lang] then
        to_install[#to_install + 1] = lang
      end
    end
    if #to_install > 0 then
      ts.install(to_install):await(vim.schedule_wrap(function()
        for _, lang in ipairs(to_install) do
          installed[lang] = true
        end
      end))
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
        if not can_build then
          pcall(vim.treesitter.start, ev.buf, lang) -- bundled parsers only
          return
        end
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
