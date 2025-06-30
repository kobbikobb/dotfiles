return { -- Useful plugin to show you pending keybinds.
	"folke/which-key.nvim",
	event = "VimEnter", -- Sets the loading event to 'VimEnter'
	opts = {
		-- delay between pressing a key and opening which-key (milliseconds)
		-- this setting is independent of vim.opt.timeoutlen
		delay = 0,
		icons = {
			-- set icon mappings to true if you have a Nerd Font
			mappings = vim.g.have_nerd_font,
			-- If you are using a Nerd Font: set icons.keys to an empty table which will use the
			-- default which-key.nvim defined Nerd Font icons, otherwise define a string table
			keys = vim.g.have_nerd_font and {} or {
				Up = "<Up> ",
				Down = "<Down> ",
				Left = "<Left> ",
				Right = "<Right> ",
				C = "<C-…> ",
				M = "<M-…> ",
				D = "<D-…> ",
				S = "<S-…> ",
				CR = "<CR> ",
				Esc = "<Esc> ",
				ScrollWheelDown = "<ScrollWheelDown> ",
				ScrollWheelUp = "<ScrollWheelUp> ",
				NL = "<NL> ",
				BS = "<BS> ",
				Space = "<Space> ",
				Tab = "<Tab> ",
				F1 = "<F1>",
				F2 = "<F2>",
				F3 = "<F3>",
				F4 = "<F4>",
				F5 = "<F5>",
				F6 = "<F6>",
				F7 = "<F7>",
				F8 = "<F8>",
				F9 = "<F9>",
				F10 = "<F10>",
				F11 = "<F11>",
				F12 = "<F12>",
			},
		},

		-- Document existing key chains
		spec = {
			{ "<leader>c", group = "[c]ode", mode = { "n", "x" } },
			{ "<leader>d", group = "[d]ocument" },
			{ "<leader>r", group = "[r]ename" },
			{ "<leader>s", group = "[s]plit" },
			{ "<leader>f", group = "[f]ind" },
			{ "<leader>g", group = "[g]it" },
			{ "<leader>n", group = "[n]avigate  (tree menu)" },
			{ "<leader>w", group = "[w]orkspace" },
			{ "<leader>t", group = "[t]est" },
			{ "<leader>T", group = "[T]ab" },
			{ "<leader>h", group = "Git [h]unk", mode = { "n", "v" } },
			{ "<leader>a", group = "H[a]rpoon" },
			{ "<leader>x", group = "[x] Trouble!" },
		},
	},
}
