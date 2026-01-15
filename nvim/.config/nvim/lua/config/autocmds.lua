-- Auto open README file when starting nvim with a directory
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		-- Defer to let nvim-tree and other plugins load first
		vim.defer_fn(function()
			-- Check if we started with a directory (no file buffer open yet)
			local buffers = vim.api.nvim_list_bufs()
			local has_file_buffer = false

			for _, buf in ipairs(buffers) do
				if vim.api.nvim_buf_is_loaded(buf) then
					local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
					local bufname = vim.api.nvim_buf_get_name(buf)
					-- Check if there's a normal file buffer (not empty, not special)
					if buftype == "" and bufname ~= "" and vim.fn.isdirectory(bufname) == 0 then
						has_file_buffer = true
						break
					end
				end
			end

			-- Only auto-open if no file buffer exists
			if not has_file_buffer then
				local cwd = vim.fn.getcwd()
				local file_to_open = nil

				-- Try to open README.md (case insensitive)
				local readme_variants = { "README.md", "readme.md", "Readme.md", "README.MD" }
				for _, readme in ipairs(readme_variants) do
					local readme_path = cwd .. "/" .. readme
					if vim.fn.filereadable(readme_path) == 1 then
						file_to_open = readme_path
						break
					end
				end

				-- Open the file if we found one
				if file_to_open then
					vim.cmd("edit " .. vim.fn.fnameescape(file_to_open))
				end
			end
		end, 100) -- Wait 100ms for other plugins to load
	end,
})
