local keymaps = require("roger.core.keymaps")

return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		on_attach = keymaps.gitsigns,
	},
}
