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
				"terraformls",
				"helm_ls",
				"dockerls",
				"tflint",
				"bashls",
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
				"ktlint",
			},
		})

            -- Configure ktlint to automatically format Kotlin files on save
            local function ktlint_autocmd()
                vim.api.nvim_create_autocmd("BufWritePost", {
                    pattern = "*.kt",
                    callback = function()
                        vim.fn.system("ktlint -F " .. vim.fn.expand("%"))
                    end,
                })
            end

            ktlint_autocmd()
	end,
}
