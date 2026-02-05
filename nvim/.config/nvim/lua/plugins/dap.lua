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

            dap_python.setup("uv")
			dap_python.test_runner = "pytest"

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
