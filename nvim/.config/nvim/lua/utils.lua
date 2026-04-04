local M = {}

function M.get_python_path()
	-- Check local venvs first
	local venv_paths = {
		".venv/bin/python",
		"venv/bin/python",
		".env/bin/python",
		"env/bin/python",
	}
	for _, path in ipairs(venv_paths) do
		local full_path = vim.fn.getcwd() .. "/" .. path
		if vim.fn.executable(full_path) == 1 then
			return full_path
		end
	end

	-- Check .python-version for pyenv virtualenv
	local pv_file = vim.fn.getcwd() .. "/.python-version"
	if vim.fn.filereadable(pv_file) == 1 then
		local name = vim.fn.readfile(pv_file)[1]:gsub("%s+", "")
		local pyenv_path = vim.fn.expand("~/.pyenv/versions/" .. name .. "/bin/python")
		if vim.fn.executable(pyenv_path) == 1 then
			return pyenv_path
		end
	end

	return vim.fn.exepath("python3") or vim.fn.exepath("python")
end

return M
