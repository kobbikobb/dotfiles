return {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
        "nvim-treesitter/nvim-treesitter-refactor",
        "piersolenski/telescope-import.nvim",
        "windwp/nvim-ts-autotag",
    },
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
       
        local treesitter = require("nvim-treesitter.configs")

        treesitter.setup {
            ensure_installed = {
                "lua",
                "vim",
                "markdown",
                "html",
                "javascript",
                "typescript",
                "kotlin",
                "java",
                "python"
            },
            sync_install = false,
            auto_install = true,
            indent = { enable = true },
            highlight = {
                enable = true,
            },
            autotag = {
                enable = true,
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-space>",
                    node_incremental = "<C-space>",
                    scope_incremental = false,
                    node_decremental = "<bs>",
                },
            },
            refactor = {
                highlight_definitions = {
                    enable = true,
                    clear_on_cursor_move = true,
                },
                highlight_current_scope = { enable = true },
                smart_rename = {
                    enable = true,
                    keymaps = {
                        smart_rename = "grr"
                    }
                },
                navigation = {
                    enable = true,
                    keymaps = {
                        goto_definition = "gnd",
                        list_definitions = "gnD",
                        list_definitions_toc = "gO",
                        goto_next_usage = "<a-*>",
                        goto_previous_usage = "<a-#>"
                    }
                }
            }
        }
        require("telescope").load_extension("import")
    end
}
