-- Common

-- Map <Leader><Tab> to switch to the last opened file
vim.api.nvim_set_keymap('n', '<Leader><Tab>', ':b#<CR>', { noremap = true, silent = true })
vim.keymap.set('i', 'jk', '<ESC>', { desc = 'Exit insert mode with jk'})
vim.keymap.set('n', '<leader>nh', ':nohl<CR>', { desc = 'Clear searchn highlights'})

-- Increment / Decrement Numbers
vim.keymap.set('n', '<leader>+', '<C-a>', { desc = 'Increment number'})
vim.keymap.set('n', '<leader>-', '<C-x>', { desc = 'Decrement number'})

-- Window management
vim.keymap.set('n', '<leader>sv', '<C-w>v', { desc = 'Split window vertically'})
vim.keymap.set('n', '<leader>sh', '<C-w>s', { desc = 'Split window horizontally'})
vim.keymap.set('n', '<leader>se', '<C-w>=', { desc = 'Makes split equal size'})
vim.keymap.set('n', '<leader>sx', '<cmd>close<CR>', { desc = 'Close current split'})

vim.keymap.set('n', '<leader>tbo', '<cmd>tabnew<CR>', { desc = 'Open new tab'})
vim.keymap.set('n', '<leader>tbx', '<cmd>tabclose<CR>', { desc = 'Close current tab'})
vim.keymap.set('n', '<leader>tbn', '<cmd>tabn<CR>', { desc = 'Go to next tab'})
vim.keymap.set('n', '<leader>tbp', '<cmd>tabp<CR>', { desc = 'Go to previous tab'})
vim.keymap.set('n', '<leader>tbf', '<cmd>tabnew %<CR>', { desc = 'Open current buffer in new tab'})

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Tree maps
vim.keymap.set('n', '<leader>nt', ':NvimTreeToggle<CR>', { noremap = true, silent = true, desc = 'Toggle file explorer' })
vim.keymap.set('n', '<leader>nf', ':NvimTreeFocus<CR>', { noremap = true, silent = true, desc = 'Focus on tree'})
vim.keymap.set('n', '<leader>nn', ':NvimTreeFindFile<CR>', { noremap = true, silent = true, desc = 'Filter on file in tree' })
vim.keymap.set('n', '<leader>nc', ':NvimTreeCollapse<CR>', { noremap = true, silent = true, desc = 'Close file tree' })

-- Telescope maps 
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Telescope find recent files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fc', builtin.grep_string, { desc = 'Telescope grep string' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fhe', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>fgi', builtin.git_status, { desc = 'Telescope git status' })
vim.api.nvim_set_keymap('n', '<leader>fi', ':Telescope import<CR>', { noremap = true, silent = true })

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

