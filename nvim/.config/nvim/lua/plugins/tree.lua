return {
	-- or, branch = "0.1.x",
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("nvim-tree").setup({
			filters = {
				custom = { "node_modules", ".bin", "dist", "__pycache__", ".idea", ".vscode" },
			},
			git = {
				enable = true,
				ignore = false,
			},
			view = {
				width = 35,
				relativenumber = true,
			},
			update_focused_file = {
				enable = true,
				update_cwd = true,
			},
		})

		-- Tree maps
		vim.keymap.set(
			"n",
			"<leader>nt",
			":NvimTreeToggle<CR>",
			{ noremap = true, silent = true, desc = "Toggle file explorer" }
		)
		vim.keymap.set(
			"n",
			"<leader>nf",
			":NvimTreeFocus<CR>",
			{ noremap = true, silent = true, desc = "Focus on tree" }
		)
		vim.keymap.set(
			"n",
			"<leader>nn",
			":NvimTreeFindFile<CR>",
			{ noremap = true, silent = true, desc = "Filter on file in tree" }
		)
		vim.keymap.set(
			"n",
			"<leader>nc",
			":NvimTreeCollapse<CR>",
			{ noremap = true, silent = true, desc = "Close file tree" }
		)
	end,
}
