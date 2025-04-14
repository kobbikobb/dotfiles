return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		"nvim-neotest/neotest-jest",
		"marilari88/neotest-vitest",
		"weilbith/neotest-gradle",
	},
	config = function()
		require("neotest").setup({
			adapters = {
				require("neotest-jest")({
					jestCommand = "npm test --",
					cwd = function(path)
						return vim.fn.getcwd()
					end,
				}),
				require("neotest-vitest"),
				require("neotest-gradle"),
			},
		})
	end,
}
