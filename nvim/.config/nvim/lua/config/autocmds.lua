-- Auto open first file when starting nvim with a directory
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

				-- Try to open README.md first (case insensitive)
				local readme_variants = { "README.md", "readme.md", "Readme.md", "README.MD" }
				local readme_found = false

				for _, readme in ipairs(readme_variants) do
					local readme_path = cwd .. "/" .. readme
					if vim.fn.filereadable(readme_path) == 1 then
						vim.cmd("edit " .. vim.fn.fnameescape(readme_path))
						readme_found = true
						break
					end
				end

				-- If no README, open the first file in the directory
				if not readme_found then
					local files = vim.fn.globpath(cwd, "*", false, true)
					for _, file in ipairs(files) do
						if vim.fn.isdirectory(file) == 0 and vim.fn.filereadable(file) == 1 then
							vim.cmd("edit " .. vim.fn.fnameescape(file))
							break
						end
					end
				end
			end
		end, 100) -- Wait 100ms for other plugins to load
	end,
})
