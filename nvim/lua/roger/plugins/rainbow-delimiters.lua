return {
  "HiPhish/rainbow-delimiters.nvim",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local rainbow_delimiters = require("rainbow-delimiters")

    vim.g.rainbow_delimiters = {
      strategy = {
        -- 預設大多數檔案使用 global，
        -- Common Lisp 等需求複雜語言可切換成 local
        [""] = rainbow_delimiters.strategy["global"],
      },
      query = {
        [""] = "rainbow-delimiters",
        latex = "rainbow-blocks",
        javascript = "rainbow-delimiters-react",
      },
      highlight = {
        -- "RainbowDelimiterRed",
        -- "RainbowDelimiterYellow",
        -- "RainbowDelimiterBlue",
        -- "RainbowDelimiterOrange",
        -- "RainbowDelimiterGreen",
        -- "RainbowDelimiterViolet",
        -- "RainbowDelimiterCyan",
        "CustomRainbowYellow",
        "CustomRainbowCyan",
        "CustomRainbowOrange",
      },
      blacklist = { "c", "cpp", "lua" },
    }
    vim.api.nvim_set_hl(0, "CustomRainbowYellow", { fg = "#FFFF00" })
    vim.api.nvim_set_hl(0, "CustomRainbowCyan",   { fg = "#00FFFF" })
    vim.api.nvim_set_hl(0, "CustomRainbowOrange", { fg = "#FFA500" })
  end,
}
