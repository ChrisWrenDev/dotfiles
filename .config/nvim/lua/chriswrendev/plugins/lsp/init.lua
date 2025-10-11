return {
    -- Lsp notifications
    {
        "j-hui/fidget.nvim",
        opts = {},
    },
    -- Lsp client wrapper
    {
        "neovim/nvim-lspconfig",
        dependencies = {

            {
                "williamboman/mason.nvim",
                config = function()
                    require("mason").setup({ PATH = "append" })
                end,
            },

            "williamboman/mason-lspconfig.nvim",
            -- Auto-install NON-LSP tools (formatters/linters) on start
            {
                "WhoIsSethDaniel/mason-tool-installer.nvim",
                config = function()
                    require("mason-tool-installer").setup({
                        ensure_installed = {
                            -- formatters/linters you’re using
                            "stylua",
                            "prettierd", "prettier",
                            "black", "isort",
                            "goimports", "gofumpt",
                            -- add more if you use them: "ruff", "eslint_d", "shfmt", "shellcheck", etc.
                        },
                        run_on_start = true,
                        start_delay = 3000, -- let mason init first
                        auto_update = false,
                        debounce_hours = 5,
                    })
                end,
            },
            "saghen/blink.cmp",
            "RRethy/vim-illuminate",
        },
        event = "BufReadPre",
        config = function()
            require("chriswrendev.plugins.lsp.config")
            require("chriswrendev.plugins.lsp.handlers")
        end,
    },
    -- code formatters
    {
        "nvimtools/none-ls.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        event = "LspAttach",
        config = function()
            local nls = require("null-ls")
            -- local formatting = nls.builtins.formatting
            local diagnostics = nls.builtins.diagnostics

            nls.setup({
                debug = false,
                sources = {
                    diagnostics.yamllint.with({
                        args = require("chriswrendev.plugins.lsp.lang.yamllint"),
                    }),
                    -- formatting.stylua,
                    -- formatting.prettierd.with({
                    --     disabled_filetypes = { "markdown", "yaml", "html" },
                    -- }),
                    -- formatting.sql_formatter,
                    -- formatting.pg_format,  -- For PostgreSQL-specific
                },
            })
        end,
    },
}
