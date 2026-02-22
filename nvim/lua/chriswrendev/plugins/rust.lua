return {
    "mrcjkb/rustaceanvim",
    version = "^4", -- recommended
    ft = { "rust" },
    dependencies = {
        "neovim/nvim-lspconfig",
    },
    opts = {
        server = {
            on_attach = function(client, bufnr)
                -- reuse your existing LSP keymaps + illuminate attach
                require("chriswrendev.plugins.lsp.opts").on_attach(client, bufnr)

                -- Rust-only keymaps
                local map = function(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, noremap = true, desc = desc })
                end

                map("n", "<leader>rm", "<cmd>RustLsp expandMacro<cr>", "Rust: Expand macro")
                map("n", "<leader>rd", "<cmd>RustLsp openDocs<cr>", "Rust: Open docs")
                map("n", "<leader>rj", "<cmd>RustLsp joinLines<cr>", "Rust: Join lines")
                map("n", "<leader>rh", "<cmd>RustLsp hover actions<cr>", "Rust: Hover actions")
            end,
            settings = {
                ["rust-analyzer"] = {
                    cargo = {
                        allFeatures = true,
                    },
                    procMacro = {
                        enable = true,
                    },
                    checkOnSave = {
                        command = "clippy",
                        extraArgs = { "--no-deps" },
                    },
                },
            },
        },
    },
}
