local M = {}

M.computer_name_ob = "Roger's MacBook Pro"

-- Machine-local overrides (gitignored), e.g. on a server with a disk quota:
--   return { mason_skip = { "basedpyright", "json-lsp" } }
local local_file = vim.fn.stdpath("config") .. "/lua/roger/core/config_local.lua"
if vim.uv.fs_stat(local_file) then
  M = vim.tbl_extend("force", M, require("roger.core.config_local"))
end

return M
