require("null-ls").setup({
    sources = {
        require("null-ls").builtins.formatting.rustfmt,
        -- require("null-ls").builtins.diagnostics.autopep8,
        require("null-ls").builtins.completion.spell,
    },
    on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = augroup,
                buffer = bufnr,
                callback = function()
                    -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
                    vim.lsp.buf.format({bufnr = bufnr})
                end,
            })
        end
    end,
})
