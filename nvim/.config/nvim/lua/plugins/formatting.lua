return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				javascript = { "prettier", "biome" },
				typescript = { "prettier", "biome" },
				javascriptreact = { "prettier", "biome" },
				typescriptreact = { "prettier", "biome" },
				svelte = { "prettier", "biome" },
				css = { "prettier", "biome" },
				html = { "prettier", "biome" },
				json = { "prettier", "biome" },
				yaml = { "prettier", "biome" },
				markdown = { "prettier", "biome" },
				graphql = { "prettier", "biome" },
				liquid = { "prettier", "biome" },
				lua = { "stylua" },
				python = { "isort", "black" },
				terraform = { "terraform_fmt" },
			},
			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			},
		})

		conform.formatters.biome = {
 			command = "npx",
 			condition = function(ctx)
 				if vim.fn.executable("npx") ~= 1 then
 					return false
 				end
 				local root = ctx and ctx.root or vim.fn.getcwd()
 				local biome_config = root .. "/biome.json"
 				local biome_dot_config = root .. "/.biome.json"
 				return vim.fn.filereadable(biome_config) == 1 or vim.fn.filereadable(biome_dot_config) == 1
 			end,
 			args = { "biome", "format", "--stdin-file-path", "$FILENAME" },
 			stdin = true,
		}

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
