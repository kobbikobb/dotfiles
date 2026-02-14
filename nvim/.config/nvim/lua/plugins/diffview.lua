return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewOpen", "DiffviewClose" },
	keys = {
		{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Git Diff Sidebar" },
		{ "<leader>gx", "<cmd>DiffviewClose<cr>", desc = "Close Diff View" },
	},
	opts = {
		file_panel = {
			listing_style = "tree",
			win_config = { width = 35 },
		},
	},
}
