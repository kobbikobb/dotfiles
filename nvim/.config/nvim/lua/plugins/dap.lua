return {
	{
		"mfussenegger/nvim-dap",
	},
	{
		"mfussenegger/nvim-dap-python",
		ft = "python",
		dependencies = {
			"mfussenegger/nvim-dap",
		},
		config = function()
			local dap = require("dap")
			local dap_python = require("dap-python")

			-- Resolve Python path from uv venv if available
			local function get_python_path()
				local cwd = vim.fn.getcwd()
				local uv_venv = cwd .. "/.venv/bin/python"
				if vim.fn.executable(uv_venv) == 1 then
					return uv_venv
				end
				return "python3"
			end

			dap_python.setup(vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python")

			-- Use pytest for test runner
			dap_python.test_runner = "pytest"

			-- Find main.py or __main__.py in project
			local function find_main()
				local cwd = vim.fn.getcwd()
				-- Try common locations
				local candidates = {
					cwd .. "/main.py",
					cwd .. "/src/main.py",
					cwd .. "/__main__.py",
					cwd .. "/src/__main__.py",
				}
				for _, path in ipairs(candidates) do
					if vim.fn.filereadable(path) == 1 then
						return path
					end
				end
				-- Fallback: search for any main.py
				local result = vim.fn.globpath(cwd, "**/main.py", false, true)
				if #result > 0 then
					return result[1]
				end
				-- Last resort: use current file
				return "${file}"
			end

			-- Add custom configurations for different Python debugging scenarios
			dap.configurations.python = {
				{
					type = "python",
					request = "launch",
					name = "Run main.py",
					program = find_main,
					pythonPath = get_python_path,
					console = "integratedTerminal",
					justMyCode = true,
				},
				{
					type = "python",
					request = "launch",
					name = "Run with args/env",
					program = find_main,
					pythonPath = get_python_path,
					console = "integratedTerminal",
					justMyCode = true,
					args = function()
						local args_string = vim.fn.input("Arguments: ")
						return vim.split(args_string, " ")
					end,
					env = function()
						local env_string = vim.fn.input("Environment (KEY=value KEY2=value2): ")
						local env = {}
						for pair in env_string:gmatch("%S+") do
							local key, value = pair:match("([^=]+)=(.+)")
							if key and value then
								env[key] = value
							end
						end
						return env
					end,
				},
			}
		end,
	},
	{
		"theHamsta/nvim-dap-virtual-text",
		dependencies = { "mfussenegger/nvim-dap" },
		opts = {
			enabled = true,
			highlight_changed_variables = true,
		},
	},
	{
		"jay-babu/mason-nvim-dap.nvim",
		dependencies = {
			"mfussenegger/nvim-dap",
			"mason-org/mason.nvim",
		},
		opts = {
			handlers = {},
		},
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio"
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup()

			-- Auto-open/close UI
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			-- Debug keymaps
			vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue/Start" })
			vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step Into" })
			vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Step Over" })
			vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Step Out" })
			vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
			vim.keymap.set("n", "<leader>dB", function()
				dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
			end, { desc = "Conditional Breakpoint" })
			vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "Terminate" })
			vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "Toggle REPL" })
			vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Toggle UI" })
		end,
	},
}
