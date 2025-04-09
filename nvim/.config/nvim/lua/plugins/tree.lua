return {
    -- or, branch = '0.1.x',
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        require'nvim-tree'.setup {
            filters = {
                custom = {'node_modules', 'bin', 'dist', '__pycache__', '.idea', '.vscode'},
            },
            view = {
                width = 35,
                relativenumber = true
            },
            update_focused_file = {
                enable = true,
                update_cwd = true
            }
        }
    end
}
