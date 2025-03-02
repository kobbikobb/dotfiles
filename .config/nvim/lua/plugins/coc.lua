return {
    'neoclide/coc.nvim',
    branch = "release",
    build = "npm ci && npm run build",
    config = function()
        vim.g.coc_global_extensions = {
            'coc-tsserver',
            'coc-eslint',
            'coc-prettier',
        }
    end
}
