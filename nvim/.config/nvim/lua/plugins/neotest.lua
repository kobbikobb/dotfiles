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
				require("neotest-python")({
					dap = { justMyCode = false },
					runner = "pytest",
					python = function()
						-- Try to find python in virtual environment first
						local venv_paths = {
							".venv/bin/python",
							"venv/bin/python",
							".env/bin/python",
							"env/bin/python",
						}
						for _, path in ipairs(venv_paths) do
							local full_path = vim.fn.getcwd() .. "/" .. path
							if vim.fn.executable(full_path) == 1 then
								return full_path
							end
						end
						-- Fall back to system python3
						return vim.fn.exepath("python3") or vim.fn.exepath("python")
					end,
				}),
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
