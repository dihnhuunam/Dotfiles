return {
    {
        "nvim-telescope/telescope.nvim",
        version = "*",

        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",

            -- Improve Telescope sorting performance
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
            },
        },

        config = function()
            local telescope = require("telescope")
            local builtin = require("telescope.builtin")

            telescope.setup({
                defaults = {
                    -- Show results using horizontal layout
                    layout_strategy = "horizontal",

                    layout_config = {
                        horizontal = {
                            preview_width = 0.55,
                        },
                    },
                },

                pickers = {
                    find_files = {
                        -- Show hidden files such as .gitignore and .clang-format
                        -- Files ignored by .gitignore are still excluded
                        hidden = true,
                    },
                },
            })

            -- Enable native fuzzy sorter
            telescope.load_extension("fzf")

            -- Find files and respect .gitignore
            vim.keymap.set("n", "<leader>ff", builtin.find_files, {
                desc = "Find files",
            })

            -- Search text inside project and respect .gitignore
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, {
                desc = "Live grep",
            })

            -- Search opened buffers
            vim.keymap.set("n", "<leader>fb", builtin.buffers, {
                desc = "Find buffers",
            })

            -- Search Neovim help
            vim.keymap.set("n", "<leader>fh", builtin.help_tags, {
                desc = "Find help",
            })

            -- Show Telescope pickers
            vim.keymap.set("n", "<leader>ft", builtin.builtin, {
                desc = "Telescope builtins",
            })

            -- Find all files, including files ignored by .gitignore
            vim.keymap.set("n", "<leader>fF", function()
                builtin.find_files({
                    hidden = true,
                    no_ignore = true,
                })
            end, {
                desc = "Find all files",
            })
        end,
    },
}
