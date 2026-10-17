-- Language tools install on first use: opening a file type installs its Mason
-- packages below (server, formatter, linter); mason-lspconfig then enables the
-- server and it attaches to the open buffers. gopls / golangci-lint, pylint,
-- cppcheck and chktex come from the system instead (see initialization.sh).
-- `mason_skip` in core/config_local.lua keeps chosen packages off a machine.
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

-- Package sources that need a runtime on PATH (Mason would fail without it)
local runtime_for = { npm = "npm", pypi = "python3", cargo = "cargo", golang = "go", gem = "gem" }

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
  local requested = {} -- filetypes already handled this session
  local usable = {} -- runtime -> bool, checked once on first need

  -- Mason's pip needs python >= 3.8 (e.g. RHEL 8 ships 3.6)
  local function runtime_usable(runtime)
    if usable[runtime] == nil then
      usable[runtime] = vim.fn.executable(runtime) == 1
      if usable[runtime] and runtime == "python3" then
        vim.fn.system({ "python3", "-c", "import sys; sys.exit(sys.version_info < (3, 8))" })
        usable[runtime] = vim.v.shell_error == 0
      end
    end
    return usable[runtime]
  end

  local function install_for(ft)
    local wanted = packages_by_ft[ft]
    if not wanted or requested[ft] then
      return
    end
    requested[ft] = true
    for _, runtime in pairs(runtime_for) do -- probe here: the callback below may run in a fast event
      runtime_usable(runtime)
    end
    local registry = require("mason-registry")
    registry.refresh(function() -- downloads the registry on a new machine
      local started, blocked = {}, {}
      for _, name in ipairs(wanted) do
        local ok, pkg = pcall(registry.get_package, name)
        if ok and not skip[name] and not pkg:is_installed() and not pkg:is_installing() then
          local runtime = runtime_for[pkg.spec.source.id:match("^pkg:(%w+)/")]
          if runtime and not usable[runtime] then
            blocked[#blocked + 1] = ("%s (needs %s%s)"):format(name, runtime, runtime == "python3" and " >= 3.8" or "")
          else
            started[#started + 1] = pkg
          end
        end
      end
      if #blocked > 0 then
        notify("Skipped " .. table.concat(blocked, ", "), vim.log.levels.WARN)
      end
      if #started == 0 then
        return
      end
      local names = vim.tbl_map(function(pkg) return pkg.name end, started)
      notify(("Installing %s for %s ..."):format(table.concat(names, ", "), ft))
      local pending, failed = #started, {}
      for _, pkg in ipairs(started) do
        pkg:install({}, function(success, err)
          if not success then
            failed[#failed + 1] = ("%s: %s"):format(pkg.name, tostring(err))
          end
          pending = pending - 1
          if pending == 0 and #failed == 0 then
            notify(("%s ready"):format(table.concat(names, ", ")))
          elseif pending == 0 then
            notify("Install failed\n" .. table.concat(failed, "\n"), vim.log.levels.ERROR)
          end
        end)
      end
    end)
  end

  -- Real files only: hover docs and noice popups are markdown "nofile" buffers
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
      -- venvs start with the system's pip, which can be too old for current
      -- wheels (e.g. pip 20 on Ubuntu 20.04 cannot install clang-format)
      pip = { upgrade_pip = true },
    })
    -- Enables every installed server, including ones installed later on
    require("mason-lspconfig").setup({ automatic_enable = true })
    setup_on_demand()
  end,
}
