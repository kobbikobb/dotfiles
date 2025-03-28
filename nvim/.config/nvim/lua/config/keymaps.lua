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
vim.api.nvim_set_keymap("n", "gd", "<Plug>(coc-definition)", { silent = true, nowait = true })
vim.api.nvim_set_keymap("n", "gy", "<Plug>(coc-type-definition)", { silent = true, nowait = true })
vim.api.nvim_set_keymap("n", "gi", "<Plug>(coc-implementation)", { silent = true, nowait = true })
vim.api.nvim_set_keymap("n", "gr", "<Plug>(coc-references)", { silent = true, nowait = true })
vim.api.nvim_set_keymap('n', '<leader>ca', '<Plug>(coc-codeaction)', { noremap = true, silent = true })

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

-- Noetest
local neotest = require("neotest")

vim.keymap.set("n", "<leader>tn", function() neotest.run.run() end, { desc = "Run nearest test" })
vim.keymap.set("n", "<leader>tf", function() neotest.run.run(vim.fn.expand("%")) end, { desc = "Run current file" })
vim.keymap.set("n", "<leader>td", function() neotest.run.run({ strategy = "dap" }) end, { desc = "Debug nearest test" })
vim.keymap.set("n", "<leader>ts", function() neotest.run.stop() end, { desc = "Stop nearest test" })
vim.keymap.set("n", "<leader>ta", function() neotest.run.attach() end, { desc = "Attach to nearest test" })
vim.keymap.set("n", "<leader>ts", function() neotest.summary.toggle() end, { desc = "Toggle summary" })

-- Harpoon
local hmark = require("harpoon.mark")
local hui = require("harpoon.ui")

vim.keymap.set("n", "<leader>ha", function() hmark.add_file() end, { desc = "Add file" })
vim.keymap.set("n", "<leader>hm", function() hui.toggle_quick_menu() end, { desc = "Toggle menu" })
vim.keymap.set("n", "<leader>hn", function() hui.nav_next() end, { desc = "Nav next" })
vim.keymap.set("n", "<leader>tp", function() hui.nav_prev() end, { desc = "Nav prev" })

vim.keymap.set("n", "<leader>hh", function() hui.nav_file(1) end, { desc = "Nav to 1" })
vim.keymap.set("n", "<leader>hj", function() hui.nav_file(2) end, { desc = "Nav to 2" })
vim.keymap.set("n", "<leader>hk", function() hui.nav_file(3) end, { desc = "Nav to 3" })
vim.keymap.set("n", "<leader>hl", function() hui.nav_file(4) end, { desc = "Nav to 4" })

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

