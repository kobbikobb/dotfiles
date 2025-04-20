return {
	"ThePrimeagen/harpoon",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		require("harpoon").setup()

		-- Harpoon maps
		local hmark = require("harpoon.mark")
		local hui = require("harpoon.ui")

		vim.keymap.set("n", "<leader>ha", function()
			hmark.add_file()
		end, { desc = "Add file" })
		vim.keymap.set("n", "<leader>hm", function()
			hui.toggle_quick_menu()
		end, { desc = "Toggle menu" })
		vim.keymap.set("n", "<leader>hn", function()
			hui.nav_next()
		end, { desc = "Nav next" })
		vim.keymap.set("n", "<leader>tp", function()
			hui.nav_prev()
		end, { desc = "Nav prev" })

		vim.keymap.set("n", "<leader>hh", function()
			hui.nav_file(1)
		end, { desc = "Nav to 1" })
		vim.keymap.set("n", "<leader>hj", function()
			hui.nav_file(2)
		end, { desc = "Nav to 2" })
		vim.keymap.set("n", "<leader>hk", function()
			hui.nav_file(3)
		end, { desc = "Nav to 3" })
		vim.keymap.set("n", "<leader>hl", function()
			hui.nav_file(4)
		end, { desc = "Nav to 4" })
	end,
}
