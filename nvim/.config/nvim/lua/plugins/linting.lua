return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			svelte = { "eslint_d" },
			python = { "pylint" },
			kotlin = { "ktlint" },
		}

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		-- Auto-lint on save and InsertLeave (excluding Kotlin - too slow)
		vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				-- Skip auto-linting for Kotlin files (too slow)
				if vim.bo.filetype ~= "kotlin" then
					lint.try_lint()
				end
			end,
		})

		-- Manual linting with ktlint
		vim.keymap.set("n", "<leader>l", function()
			lint.try_lint()
		end, { desc = "Trigger linting for current file" })
	end,
}
