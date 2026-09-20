return {
    {
        "akinsho/bufferline.nvim",
        version = "*",

        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },

        config = function()
            require("bufferline").setup({
                options = {
                    mode = "buffers",
                    diagnostics = "nvim_lsp",

                    separator_style = "slant",

                    show_buffer_close_icons = true,
                    show_close_icon = true,

                    always_show_bufferline = true,
                },
            })

            vim.keymap.set("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", {
                desc = "Next buffer",
            })

            vim.keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", {
                desc = "Previous buffer",
            })

            vim.keymap.set("n", "<leader>bd", function()
                local current = vim.api.nvim_get_current_buf()
                local buffers = vim.fn.getbufinfo({ buflisted = 1 })

                if #buffers > 1 then
                    vim.cmd("bnext")
                    vim.api.nvim_buf_delete(current, { force = false })
                else
                    vim.cmd("enew")
                    vim.api.nvim_buf_delete(current, { force = false })
                end
            end, {
                desc = "Delete buffer",
            })codex
        end,
    },
}
