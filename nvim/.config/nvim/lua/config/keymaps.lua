-- Common maps

-- Map <Leader><Tab> to switch to the last opened file
vim.api.nvim_set_keymap("n", "<Leader><Tab>", ":b#<CR>", { noremap = true, silent = true })
vim.keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })
vim.keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear searchn highlights" })

-- Increment / Decrement Numbers
vim.keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
vim.keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- Window management
vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Makes split equal size" })
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

vim.keymap.set("n", "<leader>tbo", "<cmd>tabnew<CR>", { desc = "Open new tab" })
vim.keymap.set("n", "<leader>tbx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
vim.keymap.set("n", "<leader>tbn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
vim.keymap.set("n", "<leader>tbp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
vim.keymap.set("n", "<leader>tbf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
