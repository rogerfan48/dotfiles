-- Leetcode.nvim setup <<<<<<
-- INFO: use `LEETCODE_SESSION=1 nvim -c 'Leet'` to start a LeetCode session
_G.IS_LEETCODE_SESSION = (os.getenv("LEETCODE_SESSION") == "1")

if _G.IS_LEETCODE_SESSION then
  vim.opt.showtabline = 0 -- 0 = never show, 1 = only if >1 tab, 2 = always show
end
-- Disable { `neo-tree.lua`, `bufferline.lua`, `linting.lua`, `completions.lua` }
-- Customize `bufferline.lua` to simplify desc below
-- Leetcode.nvim setup >>>>>>

require("roger.core")
require("roger.lazy")
