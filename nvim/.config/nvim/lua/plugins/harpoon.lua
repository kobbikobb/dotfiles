return {
	"ThePrimeagen/harpoon",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		require("harpoon").setup()

		-- Harpoon maps
		local hmark = require("harpoon.mark")
		local hui = require("harpoon.ui")

		vim.keymap.set("n", "<leader>oa", function()
			hmark.add_file()
		end, { desc = "Add file" })
		vim.keymap.set("n", "<leader>om", function()
			hui.toggle_quick_menu()
		end, { desc = "Toggle menu" })
		vim.keymap.set("n", "<leader>on", function()
			hui.nav_next()
		end, { desc = "Nav next" })
		vim.keymap.set("n", "<leader>op", function()
			hui.nav_prev()
		end, { desc = "Nav prev" })

		vim.keymap.set("n", "<leader>oh", function()
			hui.nav_file(1)
		end, { desc = "Nav to 1" })
		vim.keymap.set("n", "<leader>oj", function()
			hui.nav_file(2)
		end, { desc = "Nav to 2" })
		vim.keymap.set("n", "<leader>ok", function()
			hui.nav_file(3)
		end, { desc = "Nav to 3" })
		vim.keymap.set("n", "<leader>ol", function()
			hui.nav_file(4)
		end, { desc = "Nav to 4" })
	end,
}
