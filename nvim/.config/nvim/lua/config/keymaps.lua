-- Common maps

-- Map <Leader><Tab> to switch to the last opened file
vim.api.nvim_set_keymap(
	"n",
	"<Leader><Tab>",
	":b#<CR>",
	{ noremap = true, silent = true, desc = "Switch to last opened file" }
)
vim.keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })
vim.keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear searchn highlights" })

-- Increment / Decrement Numbers
vim.keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
vim.keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- Window management
vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Makes split equal size" })
vim.keymap.set("n", "<leader>sc", "<cmd>close<CR>", { desc = "Close current split" })

vim.keymap.set("n", "<leader>Tn", "<cmd>tabnew<CR>", { desc = "Open new tab" })
vim.keymap.set("n", "<leader>Tc", "<cmd>tabclose<CR>", { desc = "Close current tab" })
vim.keymap.set("n", "<leader>Tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
vim.keymap.set("n", "<leader>Tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
vim.keymap.set("n", "<leader>Tb", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
