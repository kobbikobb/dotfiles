return {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")

        dashboard.section.header.val = {
          "                                                     ",
          "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
          "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
          "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
          "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
          "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
          "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
          "                                                     ",
        }

        dashboard.section.buttons.val = {
          dashboard.button("e", "  > New File", "<cmd>ene<CR>"),
          dashboard.button("SPACE nf", "  > Toggle file explorer", "<cmd>NvimTreeToggle<CR>"),
          dashboard.button("SPACE ff", "󰱼  > Find File", "<cmd>Telescope find_files<CR>"),
          dashboard.button("SPACE fr", "󰱼  > Find Recent File", "<cmd>Telescope oldfiles<CR>"),
          dashboard.button("SPACE fg", "  > Find Word (grep)", "<cmd>Telescope live_grep<CR>"),
          dashboard.button("SPACE wr", "󰁯  > Restore Session", "<cmd>SessionRestore<CR>"),
          dashboard.button("q", "  > Quit NVIM", "<cmd>qa<CR>"),
        }

        alpha.setup(dashboard.config)
    end
}
