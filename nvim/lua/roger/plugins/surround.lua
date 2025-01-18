return {
	"kylechui/nvim-surround",
	event = { "BufReadPre", "BufNewFile" },
	version = "*", -- Use for stability; omit to use `main` branch for the latest features
	config = function()
    local keymaps = require("roger.core.keymaps")
		local surround = require("nvim-surround")
		surround.setup({
      keymaps = keymaps,
		})
	end,
}
