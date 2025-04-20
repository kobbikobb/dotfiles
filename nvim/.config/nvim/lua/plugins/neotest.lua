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

		-- Noetest map
		local neotest = require("neotest")

		vim.keymap.set("n", "<leader>tn", function()
			neotest.run.run()
		end, { desc = "Run nearest test" })
		vim.keymap.set("n", "<leader>tf", function()
			neotest.run.run(vim.fn.expand("%"))
		end, { desc = "Run current file" })
		vim.keymap.set("n", "<leader>td", function()
			neotest.run.run({ strategy = "dap" })
		end, { desc = "Debug nearest test" })
		vim.keymap.set("n", "<leader>ts", function()
			neotest.run.stop()
		end, { desc = "Stop nearest test" })
		vim.keymap.set("n", "<leader>ta", function()
			neotest.run.attach()
		end, { desc = "Attach to nearest test" })
		vim.keymap.set("n", "<leader>ts", function()
			neotest.summary.toggle()
		end, { desc = "Toggle summary" })
	end,
}
