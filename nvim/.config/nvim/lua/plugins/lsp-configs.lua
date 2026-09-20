return {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
        vim.lsp.config("clangd", {
            cmd = { "clangd", "--background-index", "--clang-tidy" },
            filetypes = { "c", "cpp" },
            root_markers = { ".clangd", "compile_commands.json", "compile_flags.txt", "CMakeLists.txt", ".git" },
        })

        vim.lsp.config("pylsp", {
            cmd = { "pylsp" },
            filetypes = { "python" },
            root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
        })

        vim.diagnostic.config({
            virtual_text = true,
            severity_sort = true,
            float = { border = "rounded" },
        })

        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
            callback = function(event)
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                local function map(keys, action, description)
                    vim.keymap.set("n", keys, action, { buffer = event.buf, desc = description })
                end

                map("gd", vim.lsp.buf.definition, "Go to definition")
                map("gr", vim.lsp.buf.references, "Find references")
                map("K", vim.lsp.buf.hover, "Show documentation")
                map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
                map("<leader>ca", vim.lsp.buf.code_action, "Code actions")
                map("<leader>d", vim.diagnostic.open_float, "Show diagnostics")
                map("<leader>lf", function()
                    vim.lsp.buf.format({ bufnr = event.buf, async = true })
                end, "Format buffer")

                if client and client:supports_method("textDocument/completion") then
                    vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
                end
            end,
        })

        vim.lsp.enable({ "clangd", "pylsp" })
    end,
}
