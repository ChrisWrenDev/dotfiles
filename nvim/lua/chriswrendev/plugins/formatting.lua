return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" }, -- to disable, comment this out
    config = function()
        local conform = require("conform")

        conform.setup({
            -- Register custom Mojo formatter
            formatters = {
                mojo = {
                    command = "mojo",
                    args = { "format", "$FILENAME" },
                    stdin = false, -- mojo format operates on files, no stdin
                },
            },
            formatters_by_ft = {
                javascript = { "prettierd", "prettier", stop_after_first = true },
                typescript = { "prettierd", "prettier", stop_after_first = true },
                javascriptreact = { "prettierd", "prettier", stop_after_first = true },
                typescriptreact = { "prettierd", "prettier", stop_after_first = true }, -- <-- add prettier fallback
                svelte = { "prettierd", "prettier", stop_after_first = true },
                vue = { "prettierd", "prettier", stop_after_first = true },
                css = { "prettierd", "prettier", stop_after_first = true },
                html = { "prettierd", "prettier", stop_after_first = true },
                json = { "prettierd", "prettier", stop_after_first = true },
                yaml = { "prettierd", "prettier", stop_after_first = true },
                markdown = { "prettierd", "prettier", stop_after_first = true },
                graphql = { "prettierd", "prettier", stop_after_first = true },
                solidity = { "prettierd", "prettier", stop_after_first = true },

                lua = { "stylua" },
                terraform = { "terraform_fmt" },
                python = { "isort", "ruff_format" }, -- optionally: "black" (slower)
                mojo = { "mojo" },
                rust = { "rustfmt" },
                go = { "goimports", "gofumpt" },
                sh = { "shfmt" },
                bash = { "shfmt" },
                sql = { "sql_formatter" },
                nix = { "alejandra" },
                proto = { "buf" },
            },
            -- default options used by both manual format and format-on-save
            default_format_opts = {
                lsp_format = "fallback",
            },

            -- format on save
            format_on_save = {
                timeout_ms = 1000,
            },
        })
    end,
}
