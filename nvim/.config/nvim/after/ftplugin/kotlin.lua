-- Kotlin-specific performance optimizations for large files with many warnings

-- Further restrict diagnostics for Kotlin files
vim.diagnostic.config({
	virtual_text = false, -- Disable inline virtual text completely for Kotlin
	signs = {
		severity = { min = vim.diagnostic.severity.ERROR }, -- Only show error signs
	},
	underline = {
		severity = { min = vim.diagnostic.severity.ERROR }, -- Only underline errors
	},
}, vim.api.nvim_get_current_buf())

-- Disable semantic tokens for better performance (they can be expensive)
vim.b.semantic_tokens = false

-- Optional: Add a keymap to toggle virtual text on/off when you need to see warnings
vim.keymap.set("n", "<leader>dv", function()
	local current = vim.diagnostic.config().virtual_text
	if current == false then
		vim.diagnostic.config({ virtual_text = true })
		print("Diagnostic virtual text enabled")
	else
		vim.diagnostic.config({ virtual_text = false })
		print("Diagnostic virtual text disabled")
	end
end, { buffer = true, desc = "Toggle diagnostic virtual text" })
