return {
    -- Lsp notifications
    {
        "j-hui/fidget.nvim",
        opts = {},
    },
    -- LSP core + Mason
    {
        "neovim/nvim-lspconfig",
        event = "BufReadPre",
        dependencies = {
            {
                "b0o/schemastore.nvim",
                lazy = true, -- only loaded when required
            },

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
                            "prettierd",
                            "prettier",
                            "eslint-lsp", -- installs ESlint lsp
                            "eslint_d", -- fastest eslint deamon
                            -- Python
                            "black",
                            "isort",
                            "ruff",
                            "pyright",
                            -- Golang
                            "goimports",
                            "gofumpt",
                            "delve", -- needed for dap-go
                            "golangci-lint",
                            -- Rust
                            "rust-analyzer", -- Rustaceanvim will pick this up from Mason
                            "codelldb",
                            -- Bash
                            "bash-language-server", -- lsp
                            "shellcheck", -- diagnostics
                            "shfmt", -- formatting
                            -- Docker / kubernetes
                            "hadolint",
                            "helm-ls",
                            -- Terraform
                            "terraform-ls",
                            "terraform_fmt",
                            "tflint",
                            -- SQL
                            "sql-formatter",
                            -- Nix
                            "nixd",
                            "alejandra", -- formatter
                            -- Make
                            "checkmake",
                            -- Proto
                            "buf",
                            -- generators
                            "protoc-gen-go",
                            "protoc-gen-go-grpc",
                            -- "protoc-gen-es", "protoc-gen-connect-es", -- Typescript
                            "svelte-language-server",
                            "vue-language-server",
                            --
                            "yamllint",
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
        config = function()
            require("chriswrendev.plugins.lsp.config")
            require("chriswrendev.plugins.lsp.handlers")
        end,
    },
    -- optional: keep none-ls only if you need it
    {
        "nvimtools/none-ls.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "nvimtools/none-ls-extras.nvim" },
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local nls = require("null-ls")
            local builtins = nls.builtins
            local diagnostics = builtins.diagnostics

            nls.setup({
                debug = false,
                sources = {
                    diagnostics.yamllint.with({
                        args = require("chriswrendev.plugins.lsp.lang.yamllint"),
                    }),
                    diagnostics.golangci_lint,
                    diagnostics.hadolint, -- dockerfile linting
                    diagnostics.terraform_validate, -- terraform linting
                    -- diagnostics.shellcheck, -- bash linting (archived)
                    diagnostics.checkmake,
                },
            })
        end,
    },
}
