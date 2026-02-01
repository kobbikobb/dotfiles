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
			-- Simple, direct path to Mason's debugpy
			require("dap-python").setup(vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python")
		end,
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
			vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "[d]ebug: [c]ontinue/start" })
			vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "[d]ebug: step [i]nto" })
			vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "[d]ebug: step [o]ver" })
			vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "[d]ebug: step [O]ut" })
			vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "[d]ebug: toggle [b]reakpoint" })
			vim.keymap.set("n", "<leader>dB", function()
				dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
			end, { desc = "[d]ebug: conditional [B]reakpoint" })
			vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "[d]ebug: [t]erminate" })
			vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "[d]ebug: toggle [r]epl" })
			vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "[d]ebug: toggle [u]i" })
		end,
	},
}
