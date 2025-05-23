return {
  "windwp/nvim-autopairs",
  event = { "InsertEnter" },
  dependencies = {
    "hrsh7th/nvim-cmp",
  },
  config = function()
    local autopairs = require("nvim-autopairs")
    autopairs.setup({
      check_ts = true,
      map_bs = true,
      ts_config = {
        lua = { 'string' }, -- it will not add a pair on that treesitter node
        javascript = { 'template_string' },
        java = false,     -- don't check treesitter on java
      }
    })

    local Rule = require('nvim-autopairs.rule')
    local cond = require('nvim-autopairs.conds')
    autopairs.add_rule(Rule("*", "*", "markdown"):with_pair(cond.not_after_regex("[%w%.]")))

    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    local cmp = require("cmp")
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
  end
}
