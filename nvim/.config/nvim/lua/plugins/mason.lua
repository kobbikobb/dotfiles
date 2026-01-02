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
			"groovyls",
			"gradle_ls",
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
			end,
		},
		"neovim/nvim-lspconfig",
	},
}
