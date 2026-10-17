-- Mason packages per file type, installed the first time such a file is opened;
-- mason-lspconfig then enables the server for the open buffers. `mason_skip` in
-- core/config_local.lua keeps packages off a machine.
local packages_by_ft = {
  c = { "clangd", "clang-format" },
  cpp = { "clangd", "clang-format" },
  cuda = { "clangd", "clang-format" },
  lua = { "lua-language-server", "stylua" },
  python = { "basedpyright", "isort", "black" },
  sh = { "bash-language-server", "shellcheck", "shfmt" },
  bash = { "bash-language-server", "shellcheck", "shfmt" },
  markdown = { "marksman", "markdownlint" },
  json = { "json-lsp", "jsonlint", "prettier" },
  jsonc = { "json-lsp", "prettier" },
  yaml = { "yamllint", "prettier" },
  toml = { "taplo" },
  html = { "html-lsp", "prettier" },
  css = { "css-lsp", "prettier" },
  scss = { "css-lsp", "prettier" },
  javascript = { "typescript-language-server", "eslint_d", "prettier" },
  javascriptreact = { "typescript-language-server", "eslint_d", "prettier" },
  typescript = { "typescript-language-server", "eslint_d", "prettier" },
  typescriptreact = { "typescript-language-server", "eslint_d", "prettier" },
  vue = { "vue-language-server", "typescript-language-server", "eslint_d", "prettier" },
  tex = { "texlab", "latexindent" },
}

local function notify(msg, level)
  vim.schedule(function()
    vim.notify(msg, level or vim.log.levels.INFO, { title = "Mason" })
  end)
end

local function setup_on_demand()
  local skip = {}
  for _, name in ipairs(require("roger.core.config").mason_skip or {}) do
    skip[name] = true
  end
  local requested = {} -- file types already handled this session

  local function install_for(ft)
    local wanted = packages_by_ft[ft]
    if not wanted or requested[ft] then
      return
    end
    requested[ft] = true
    local registry = require("mason-registry")
    registry.refresh(function()
      local pkgs = {}
      for _, name in ipairs(wanted) do
        local ok, pkg = pcall(registry.get_package, name)
        if ok and not skip[name] and not pkg:is_installed() and not pkg:is_installing() then
          pkgs[#pkgs + 1] = pkg
        end
      end
      if #pkgs == 0 then
        return
      end
      local names = table.concat(vim.tbl_map(function(pkg) return pkg.name end, pkgs), ", ")
      notify(("Installing %s for %s ..."):format(names, ft))
      local pending, failed = #pkgs, {}
      for _, pkg in ipairs(pkgs) do
        pkg:install({}, function(success, err)
          if not success then
            failed[#failed + 1] = ("%s: %s"):format(pkg.name, tostring(err))
          end
          pending = pending - 1
          if pending > 0 then
            return
          end
          if #failed == 0 then
            notify(names .. " ready")
          else
            notify("Install failed\n" .. table.concat(failed, "\n"), vim.log.levels.ERROR)
          end
        end)
      end
    end)
  end

  -- Real files only: hover docs and noice popups are markdown buffers too
  local function is_file(buf)
    return vim.bo[buf].buftype == ""
  end
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("roger_mason_on_demand", { clear = true }),
    callback = function(ev)
      if is_file(ev.buf) then
        install_for(ev.match)
      end
    end,
  })
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do -- files opened before this ran
    if vim.api.nvim_buf_is_loaded(buf) and is_file(buf) then
      install_for(vim.bo[buf].filetype)
    end
  end
end

return {
  "mason-org/mason.nvim",
  dependencies = {
    "mason-org/mason-lspconfig.nvim",
  },
  config = function()
    require("mason").setup({
      pip = { upgrade_pip = true }, -- a distro's old pip can't install current wheels
    })
    require("mason-lspconfig").setup({ automatic_enable = true })
    setup_on_demand()
  end,
}
