-- Kotlin-specific performance optimizations for large files with many warnings

-- Show hints and warnings, but keep virtual_text off for performance
vim.diagnostic.config({
	virtual_text = false, -- Disable inline virtual text for performance
	signs = {
		severity = { min = vim.diagnostic.severity.HINT }, -- Show all diagnostics including unused code
	},
	underline = {
		severity = { min = vim.diagnostic.severity.HINT }, -- Underline hints too (unused code)
	},
}, vim.api.nvim_get_current_buf())

-- Disable semantic tokens for better performance (they can be expensive)
vim.b.semantic_tokens = false

-- Add keymaps for diagnostics
vim.keymap.set("n", "<leader>dv", function()
	local current = vim.diagnostic.config().virtual_text
	if current == false then
		vim.diagnostic.config({ virtual_text = true }, vim.api.nvim_get_current_buf())
		print("Diagnostic virtual text enabled")
	else
		vim.diagnostic.config({ virtual_text = false }, vim.api.nvim_get_current_buf())
		print("Diagnostic virtual text disabled")
	end
end, { buffer = true, desc = "Toggle diagnostic virtual text" })

-- Show all diagnostics for current buffer
vim.keymap.set("n", "<leader>da", function()
	vim.diagnostic.setloclist()
end, { buffer = true, desc = "Show all diagnostics in location list" })
