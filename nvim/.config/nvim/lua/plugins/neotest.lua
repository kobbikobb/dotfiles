return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		"nvim-neotest/neotest-jest",
		"marilari88/neotest-vitest",
		"kobbikobb/neotest-gradle",
		"nvim-neotest/neotest-python",
		"mfussenegger/nvim-dap-python",
	},
	config = function()
		local adapters = {}

		-- Only load JS adapters when package.json exists
		if vim.fn.filereadable(vim.fn.getcwd() .. "/package.json") == 1 then
			table.insert(adapters, require("neotest-jest")({
				jestCommand = "npm test --",
				cwd = function(path)
					return vim.fn.getcwd()
				end,
			}))
			table.insert(adapters, require("neotest-vitest"))
		end

		table.insert(adapters, require("neotest-gradle"))
		table.insert(adapters, require("neotest-python")({
			dap = {
				justMyCode = true,
			},
			runner = "pytest",
			python = function()
				return require("utils").get_python_path()
			end,
		}))

		require("neotest").setup({
			adapters = adapters,
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
		vim.keymap.set("n", "<leader>tx", function()
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
