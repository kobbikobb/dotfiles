return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")
		local mason_installer = require("mason-tool-installer")

		mason.setup({
			ui = {
				icons = {
					package_installed = "",
					package_pending = "󰝲",
					package_uninstalled = "q",
				},
			},
		})

		mason_lspconfig.setup({
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
				"terraform-ls",
			},
		})

		mason_installer.setup({
			ensure_installed = {
				"prettier",
				"stylua",
				"isort",
				"black",
				"pylint",
				"eslint_d",
				"tflint",
			},
		})
	end,
}
