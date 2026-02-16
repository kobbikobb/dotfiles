return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	dependencies = {
		"piersolenski/import.nvim",

        "nvim-lua/plenary.nvim" ,
    },
	config = function()
		-- Safely require nvim-treesitter
		local status_ok, treesitter = pcall(require, "nvim-treesitter.configs")
		if not status_ok then
			vim.notify("nvim-treesitter.configs not available yet", vim.log.levels.WARN)
			return
		end

		treesitter.setup({
			ensure_installed = {
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
			},
			sync_install = false,
			auto_install = true,
			indent = { enable = true },
			highlight = {
				enable = true,
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
		})
		
		-- Safely load telescope extension
		local telescope_status, telescope = pcall(require, "telescope")
		if telescope_status then
			telescope.load_extension("import")
		end
	end,
}
