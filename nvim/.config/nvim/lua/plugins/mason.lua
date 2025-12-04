return {
	"mason-org/mason-lspconfig.nvim",
	opts = {
		ensure_installed = {
			"ts_ls",
			"html",
			"cssls",
			"tailwindcss",
			"svelte",
			"lua_ls",
			"pyright",
			"jdtls",
			"kotlin_language_server",
			"terraformls",
			"helm_ls",
			"dockerls",
			"tflint",
			"bashls",
			"rust_analyzer",
		},
	},
	dependencies = {
		{
			"mason-org/mason.nvim",
			opts = {
				ui = {
					icons = {
						package_installed = "",
						package_pending = "󰝲",
						package_uninstalled = "q",
					},
				},
			},
		},
		{
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			opts = {
				ensure_installed = {
					"prettier",
					"stylua",
					"isort",
					"black",
					"pylint",
					"eslint_d",
					"ktlint",
				},
				auto_update = true,
				run_on_start = true,
			},
			config = function(_, opts)
				local mason_tool_installer = require("mason-tool-installer")
				mason_tool_installer.setup(opts)

				-- Auto-format Kotlin files before save using ktlint
				vim.api.nvim_create_autocmd("BufWritePre", {
					pattern = "*.kt",
					callback = function()
						local file = vim.fn.expand("%:p")
						vim.fn.system("ktlint -F " .. vim.fn.shellescape(file))
						-- Reload buffer only if it wasn't modified during formatting
						vim.cmd("checktime")
					end,
				})

				-- Auto-format Python files before save
				vim.api.nvim_create_autocmd("BufWritePre", {
					pattern = "*.py",
					callback = function()
						local file = vim.fn.expand("%:p")
						-- Run isort first (import sorting)
						vim.fn.system("isort " .. vim.fn.shellescape(file))
						-- Then run black (code formatting)
						vim.fn.system("black " .. vim.fn.shellescape(file))
						-- Reload buffer only if it wasn't modified during formatting
						vim.cmd("checktime")
					end,
				})
			end,
		},
		"neovim/nvim-lspconfig",
	},
}
