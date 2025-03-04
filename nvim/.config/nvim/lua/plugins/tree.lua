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
                custom = {'node_modules', '__pycache__', '.idea', '.vscode'},
            },
            update_focused_file = {
                enable = true,
                update_cwd = true
            }
        }
    end
}
