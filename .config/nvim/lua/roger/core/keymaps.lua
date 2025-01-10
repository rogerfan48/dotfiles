local M = {}

M.general = function()
	-- using "jk" as <esc> in INSERT, VISUAL, COMMAND, TERMNIAL are configured in "better-escape" module
	vim.keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

	vim.keymap.set("n", "<leader>ww", ":w<CR>", { desc = "Save file (:w) " })
	vim.keymap.set("n", "<leader>q<space>", ":q<CR>", { desc = "Quit current Nvim window (:q)" })
	vim.keymap.set("n", "<leader>qq", ":qa<CR>", { desc = "Quit all Nvim windows (:qa)" })

	-- yank to and paste from system clipboard
	vim.keymap.set("n", "<leader>y", '"+y', { silent = true })
	vim.keymap.set("v", "<leader>y", '"+y', { silent = true })
	vim.keymap.set("n", "<leader>p", '"+p', { silent = true })
	vim.keymap.set("v", "<leader>p", '"+p', { silent = true })

	-- increment/decrement numbers
	vim.keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
	vim.keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

	-- window management
	vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
	vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
	vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
	vim.keymap.set("n", "<leader>sx", ":close<CR>", { desc = "Close current split", silent = true })
	vim.keymap.set("n", "<leader>sm", ":MaximizerToggle<CR>", { desc = "Max/min a split", silent = true })

	-- tab management
	vim.keymap.set("n", "<leader>tn", ":tabnew<CR>", { desc = "Open new tab", silent = true })
	vim.keymap.set("n", "<leader>tx", ":tabclose<CR>", { desc = "Close current tab", silent = true })
	vim.keymap.set("n", "<tab>", ":tabn<CR>", { desc = "Go to next tab", silent = true })
	vim.keymap.set("n", "<S-tab>", ":tabp<CR>", { desc = "Go to previous tab", silent = true })
	vim.keymap.set("n", "<leader>tp", ":BufferLinePick<CR>", { desc = "Pick tab", silent = true })
	vim.keymap.set("n", "<leader>tf", ":tabnew %<CR>", { desc = "Open current buffer in new tab", silent = true })

	-- from comment.lua
	-- 'gc' + motion.   ex. gc3j(to 3 lines below), gcG(to EOF), gcc(one line)
end

M.lsp = function()
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("UserLspConfig", {}),
		callback = function(ev)
			local client = vim.lsp.get_client_by_id(ev.data.client_id)
			if client then
				vim.notify("LSP " .. client.name .. " attached to buffer " .. ev.buf, vim.log.levels.INFO)
			end

			local bufopts = { noremap = true, silent = true, buffer = ev.buf }
			local function with_desc(desc)
				return vim.tbl_extend("force", bufopts, { desc = desc })
			end
			vim.keymap.set("n", "K", vim.lsp.buf.hover, with_desc("Show hover Info"))
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, with_desc("Go to declaration"))
			vim.keymap.set("n", "gd", ":Telescope lsp_definitions<CR>", with_desc("Show LSP definitions"))
			vim.keymap.set("n", "gi", ":Telescope lsp_implementations<CR>", with_desc("Show LSP implementations"))
			vim.keymap.set("n", "gr", ":Telescope lsp_references<CR>", with_desc("Show LSP references"))
			vim.keymap.set("n", "gt", ":Telescope lsp_type_definitions<CR>", with_desc("Show LSP type definitions"))
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, with_desc("Code action"))
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, with_desc("Rename symbol"))
			vim.keymap.set("n", "]d", vim.diagnostic.goto_next, with_desc("Go to next diagnostic"))
			vim.keymap.set("n", "[d", vim.diagnostic.goto_next, with_desc("Go to previous diagnostic"))
			vim.keymap.set("n", "<leader>rs", ":LspRestart<CR>", with_desc("Restart LSP"))
		end,
	})
end

M.formatting = function()
	local conform = require("conform")
	vim.keymap.set({ "n", "v" }, "<leader>gf", function()
		conform.format({
			lsp_fallback = true,
			async = false,
			timeout_ms = 1000,
		})
	end, { desc = "Format file or range (in v)" })
end

M.linting = function()
	local lint = require("lint")
	vim.keymap.set("n", "<leader>l", function()
		lint.try_lint()
	end, { desc = "Trigger linting for current file" })
end

M.neo_tree = function()
	local function custom_toggle_neo_tree()
		-- 獲取當前的 Tab 頁索引
		local current_tab = vim.api.nvim_get_current_tabpage()

		-- 獲取當前 Tab 的所有窗口
		local tab_wins = vim.api.nvim_tabpage_list_wins(current_tab)
		local neo_tree_win = nil

		-- 找到當前 Tab 中的 Neo-tree 窗口
		for _, win in ipairs(tab_wins) do
			local buf = vim.api.nvim_win_get_buf(win)
			local buf_name = vim.api.nvim_buf_get_name(buf)
			if buf_name:match("neo%-tree filesystem") then
				neo_tree_win = win
				break
			end
		end

		if neo_tree_win then
			-- Neo-tree 在當前 Tab 中已打開，切換到該窗口或關閉
			local current_win = vim.api.nvim_get_current_win()
			if neo_tree_win == current_win then
				-- 當前在 Neo-tree 視窗中，關閉它
				vim.cmd("silent Neotree close")
			else
				-- 切換到 Neo-tree 視窗
				vim.api.nvim_set_current_win(neo_tree_win)
			end
		else
			-- Neo-tree 未開啟，打開它
			vim.cmd("silent Neotree toggle")
		end
	end

	-- vim.keymap.set("n", "<C-j>", ":Neotree toggle<cr>", {})
	vim.keymap.set("n", "<leader>j", custom_toggle_neo_tree, { desc = "Toggle Neo-tree" })
end

M.telescope = function()
	local builtin = require("telescope.builtin")
	vim.keymap.set("n", "<leader>fj", builtin.find_files, { desc = "Fuzzy find files in cwd" })
	vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Fuzzy find recent files" })
	vim.keymap.set("n", "<leader>fs", builtin.live_grep, { desc = "Find string in cwd" })
	vim.keymap.set("n", "<leader>fc", builtin.grep_string, { desc = "Find string under cursor" })
	vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
	vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
	vim.keymap.set("n", "<leader>ft", ":TodoTelescope<cr>", { desc = "Find todos" })
end

M.auto_session = function()
	vim.keymap.set("n", "<leader>ws", "<cmd>SessionSave<CR>", { desc = "Save session for root dir" })
	vim.keymap.set("n", "<leader>wr", "<cmd>SessionRestore<CR>", { desc = "Restore session for cwd" })
end

M.treesitter = {
	init_selection = "<C-.>",
	node_incremental = "<C-.>",
	scope_incremental = false,
	node_decremental = "<C-,>",
}

M.todo_comments = function()
	local todo_comments = require("todo-comments")
	vim.keymap.set("n", "]t", function()
		todo_comments.jump_next()
	end, { desc = "Next todo comment" })
	vim.keymap.set("n", "[t", function()
		todo_comments.jump_prev()
	end, { desc = "Previous todo comment" })
end

M.substitute = function()
	local substitute = require("substitute")
	vim.keymap.set("n", "s", substitute.operator, { desc = "Substitute with motion" })
	vim.keymap.set("n", "ss", substitute.line, { desc = "Substitute line" })
	vim.keymap.set("n", "S", substitute.eol, { desc = "Substitute to end of line" })
	vim.keymap.set("x", "s", substitute.visual, { desc = "Substitute in visual mode" })
end

-- surround:
-- ys + motion + symbol: add surrounding
-- ds + symbol: delete surrounding
-- cs + ori_symbol + new_symbol: change symbol
-- symbol: ', ", (, [, {, t, f
--                        (t=tag, f=function)

M.trouble = {
	{ "<leader>xx", ":Trouble diagnostics toggle<CR>", desc = "Open trouble workspace diagnostics" },
	{ "<leader>xw", ":Trouble diagnostics toggle<CR>", desc = "Open trouble workspace diagnostics" },
	{ "<leader>xd", ":Trouble diagnostics toggle filter.buf=0<CR>", desc = "Open trouble document diagnostics" },
	{ "<leader>xq", ":Trouble quickfix toggle<CR>", desc = "Open trouble quickfix list" },
	{ "<leader>xl", ":Trouble loclist toggle<CR>", desc = "Open trouble location list" },
	{ "<leader>xt", ":Trouble todo toggle<CR>", desc = "Open todos in trouble" },
}

return M
