-- Common
-- Map <Leader><Tab> to switch to the last opened file
vim.api.nvim_set_keymap('n', '<Leader><Tab>', ':b#<CR>', { noremap = true, silent = true })

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Tree maps
vim.keymap.set('n', '<leader>nt', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>nf', ':NvimTreeFocus<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>nff', ':NvimTreeFindFile<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>nc', ':NvimTreeCollapse<CR>', { noremap = true, silent = true })

-- Coc mapping
vim.api.nvim_set_keymap("i", "<Enter>", [[pumvisible() ? coc#_select_confirm() : "\<CR>"]], { expr = true, noremap = true, silent = true })

-- Telescope maps 
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- Prettier
vim.api.nvim_set_keymap("v", "<leader>p", "<Plug>(coc-format-selected)", { silent = true })
vim.api.nvim_set_keymap("n", "<leader>p", "<Plug>(coc-format-selected)", { silent = true })
vim.api.nvim_set_keymap("n", "<leader>P", "<cmd>CocCommand editor.action.formatDocument<CR>", { noremap = true, silent = true })

-- Comment out and in
vim.api.nvim_set_keymap('v', '<leader>/', ':<C-u>lua ToggleComment()<CR>', { noremap = true, silent = true })

function ToggleComment()
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")

    local lines = vim.fn.getline(start_line, end_line)
    local all_commented = true

    for _, line in ipairs(lines) do
        if not line:match("^%s*//") then
            all_commented = false
            break
        end
    end

    for i, line in ipairs(lines) do
        if all_commented then
            lines[i] = line:gsub("^%s*//%s?", "")
        else
            lines[i] = "// " .. line
        end
    end

    vim.fn.setline(start_line, lines)
end

