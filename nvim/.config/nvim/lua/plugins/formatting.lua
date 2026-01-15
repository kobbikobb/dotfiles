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
				kotlin = { "ktlint" },
				terraform = { "terraform_fmt" },
			},
		})

		-- Custom ktlint formatter with longer timeout
		conform.formatters.ktlint = {
			command = "ktlint",
			args = { "--format", "--stdin" },
			stdin = true,
		}

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

		vim.keymap.set({ "n", "v" }, "<leader>cf", function()
			-- Use longer timeout for Kotlin files
			local timeout = vim.bo.filetype == "kotlin" and 30000 or 5000
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = timeout,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
