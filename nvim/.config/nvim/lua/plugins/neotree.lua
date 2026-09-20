return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "main",

        -- Dependencies required by Neo-tree
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",

            -- Show file and folder icons
            "nvim-tree/nvim-web-devicons",
        },

        config = function()
            require("neo-tree").setup({
                -- Close Neo-tree if it is the last remaining window
                close_if_last_window = true,

                filesystem = {
                    -- Automatically reveal the currently opened file
                    follow_current_file = {
                        enabled = true,
                    },

                    filtered_items = {
                        -- Show hidden files such as .gitignore and .clang-format
                        hide_dotfiles = false,

                        -- Show files ignored by Git
                        hide_gitignored = false,
                    },
                },

                window = {
                    -- Set Neo-tree window width
                    width = 30,

                    mappings = {
                        -- Open file or expand directory
                        ["l"] = "open",

                        -- Collapse the current directory
                        ["h"] = "close_node",
                    },
                },
            })

            -- Space + v to toggle Neo-tree
            -- reveal: select the current file in the tree
            -- left: open Neo-tree on the left side
            vim.keymap.set(
                "n",
                "<leader>e",
                "<cmd>Neotree filesystem reveal left toggle<CR>",
                { desc = "Toggle Neo-tree" }
            )
        end,
    },
}
