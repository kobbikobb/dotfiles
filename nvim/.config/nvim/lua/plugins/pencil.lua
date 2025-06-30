return {
	"preservim/vim-pencil",
	ft = { "markdown", "text", "gitcommit" },
	config = function()
		vim.g["pencil#wrapModeDefault"] = "soft"
		vim.g["pencil#conceallevel"] = 2
		vim.g["pencil#concealcursor"] = "nc"

		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "markdown", "text", "gitcommit" },
			callback = function()
				vim.cmd("Pencil")
			end,
		})
	end,
}
