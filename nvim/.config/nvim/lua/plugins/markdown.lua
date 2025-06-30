return {
	"iamcco/markdown-preview.nvim",
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	build = "cd app && npm install",
	init = function()
		vim.g.mkdp_filetypes = { "markdown" }

		-- Additional helpful settings
		vim.g.mkdp_auto_close = 0 -- Don't automatically close the preview window when changing buffers
		vim.g.mkdp_echo_preview_url = 1 -- Print the preview URL in the command line
	end,
	keys = {
		{ "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", desc = "Markdown preview toggle", ft = "markdown" },
	},
	ft = { "markdown" },
}
