return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",
	dependencies = {
		"piersolenski/import.nvim",
		"nvim-lua/plenary.nvim",
	},
	config = function()
		require("nvim-treesitter").setup({})

		-- Install parsers
		local ensure_installed = {
			"lua",
			"vim",
			"vimdoc",
			"markdown",
			"markdown_inline",
			"html",
			"javascript",
			"typescript",
			"kotlin",
			"java",
			"groovy",
			"python",
			"bash",
		}

		local installed = require("nvim-treesitter").get_installed()
		local to_install = vim.tbl_filter(function(lang)
			return not vim.tbl_contains(installed, lang)
		end, ensure_installed)

		if #to_install > 0 then
			require("nvim-treesitter").install(to_install)
		end

		-- Enable treesitter-based highlighting for all filetypes
		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				pcall(vim.treesitter.start, args.buf)
			end,
		})

		-- Safely load telescope extension
		local telescope_status, telescope = pcall(require, "telescope")
		if telescope_status then
			telescope.load_extension("import")
		end
	end,
}
