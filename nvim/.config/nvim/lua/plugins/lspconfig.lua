return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
	},
	config = function()
		local keymap = vim.keymap

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				local opts = { buffer = ev.buf, silent = true }

				-- TODO: Why is this not showing up in WhichKey?

				opts.desc = "Show LSP references"
				keymap.set("n", "gR", function()
					vim.lsp.buf.references(vim.lsp.util.make_position_params())
				end, opts)

				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", vim.lsp.buf.definition, opts)

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

				opts.desc = "See available actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

				opts.desc = "Show documentation for what is under the cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts)

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
			end,
		})

		local signs = { Error = "", Warn = "", Hint = "󰌵", Info = "" }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		-- Optimize diagnostic performance without losing information
		vim.diagnostic.config({
			update_in_insert = false, -- Don't update while typing (big performance win)
			virtual_text = {
				spacing = 4,
				prefix = "●",
			},
			float = {
				border = "rounded",
				source = "always",
			},
			severity_sort = true,
		})

		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		-- Configure lua_ls with custom settings
		vim.lsp.config("lua_ls", {
			capabilities = capabilities,
			settings = {
				Lua = {
					runtime = {
						version = "LuaJIT",
					},
					diagnostics = {
						globals = {
							"vim",
							"require",
						},
					},
				},
			},
		})

		-- Configure Kotlin language server with debouncing for better performance
		vim.lsp.config("kotlin_language_server", {
			capabilities = capabilities,
			flags = {
				debounce_text_changes = 300, -- Debounce to reduce LSP load
			},
		})

		-- Configure all other language servers with default settings
		local servers = {
			"ts_ls",
			"html",
			"cssls",
			"tailwindcss",
			"svelte",
			"pyright",
			"jdtls",
			"groovyls",
			"gradle_ls",
			"terraformls",
			"helm_ls",
			"dockerls",
			"bashls",
			"rust_analyzer",
		}

		for _, server in ipairs(servers) do
			vim.lsp.config(server, {
				capabilities = capabilities,
			})
		end

		-- Enable all configured LSP servers
		vim.lsp.enable({ "lua_ls", "kotlin_language_server", unpack(servers) })
	end,
}
