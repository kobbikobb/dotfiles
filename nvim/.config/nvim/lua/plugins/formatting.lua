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
				markdown = { "prettier", "biome" },
				graphql = { "prettier", "biome" },
				liquid = { "prettier", "biome" },
				lua = { "stylua" },
				python = function(bufnr)
					local root = vim.fs.root(bufnr, { "pyproject.toml", "ruff.toml", ".ruff.toml" })
					if root then
						if vim.uv.fs_stat(root .. "/ruff.toml") or vim.uv.fs_stat(root .. "/.ruff.toml") then
							return { "ruff_format", "ruff_organize_imports" }
						end
						local pp = root .. "/pyproject.toml"
						if vim.uv.fs_stat(pp) then
							for _, line in ipairs(vim.fn.readfile(pp)) do
								if line:match("^%[tool%.ruff") then
									return { "ruff_format", "ruff_organize_imports" }
								end
							end
						end
					end
					return { "isort", "black" }
				end,
				kotlin = { "ktlint" },
				swift = { "swiftformat" },
				terraform = { "terraform_fmt" },
				yaml = { "yamlfmt" },
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
