return {
    "nvim-treesitter/nvim-treesitter",
    -- The configs API on master supports Neovim 0.10/0.11 and CLI 0.25.x.
    branch = "master",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        local config = require("nvim-treesitter.configs")
        config.setup({
            -- Chỉ cài đặt parser cho C, C++ và Python (cùng vài parser cơ bản cho Neovim)
            ensure_installed = {
                "c",
                "cpp",
                "python",
                "lua",       -- Dùng cho file config Neovim
                "vim",       -- Dùng cho Vimscript
                "vimdoc",    -- Dùng để xem help doc trong Neovim
            },

            -- Tự động cài đặt parser nếu bạn mở loại file khác
            auto_install = true,
            sync_install = false,

            -- Bật tô màu cú pháp theo Treesitter
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },

            -- Bật tự động thụt lề (indentation)
            indent = { enable = true },
        })
    end,
}
