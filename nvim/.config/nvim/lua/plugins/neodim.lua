return {
	"zbirenbaum/neodim",
	event = "LspAttach",
	config = function()
		require("neodim").setup({
			alpha = 0.45, -- How much to dim (0-1, lower = more transparent)
			blend_color = "#000000", -- Color to blend with
			hide = {
				underline = false, -- Keep underline on unused code
				virtual_text = false, -- Keep virtual text
				signs = false, -- Keep signs in the gutter
			},
			priority = 100, -- Highlight priority
			disable = {}, -- Disable for specific filetypes if needed
		})
	end,
}
