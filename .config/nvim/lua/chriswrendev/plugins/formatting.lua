return {
    "stevearc/conform.nvim",
    lazy = true,
    event = { "BufReadPre", "BufNewFile" }, -- to disable, comment this out
    config = function()
        local conform = require("conform")

        conform.setup({
            formatters_by_ft = {
                javascript      = { "prettierd", "prettier" },
                typescript      = { "prettierd", "prettier" },
                javascriptreact = { "prettierd", "prettier" },
                typescriptreact = { "prettierd", "prettier" }, -- <-- add prettier fallback
                svelte          = { "prettierd", "prettier" },
                css             = { "prettierd", "prettier" },
                html            = { "prettierd", "prettier" },
                json            = { "prettierd", "prettier" },
                yaml            = { "prettierd", "prettier" },
                markdown        = { "prettierd", "prettier" },
                graphql         = { "prettierd", "prettier" },
                lua             = { "stylua" },
                terraform       = { "terraform_fmt" },
                python          = { "isort", "black" }, -- optionally: "ruff_format"
                rust            = { "rustfmt" },
                go              = { "goimports", "gofumpt" },
            },
        })

        vim.keymap.set({ "n", "v" }, "<leader>mp", function()
            conform.format({
                lsp_fallback = true,
                async = false,
                timeout_ms = 1000,
            })
        end, { desc = "Format file or range (in visual mode)" })
    end,
}
