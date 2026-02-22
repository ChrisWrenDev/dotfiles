return {
    "folke/trouble.nvim",
    cmd = "Trouble",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        -- warn_no_results = false, -- optional
    },
    keys = {
        { "<leader>xx", "<cmd>Trouble diagnostics toggle focus=false<cr>", desc = "Diagnostics (Trouble)" },
        {
            "<leader>xX",
            "<cmd>Trouble diagnostics toggle focus=false filter.buf=0<cr>",
            desc = "Buffer Diagnostics (Trouble)",
        },
        { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
        { "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP (Trouble)" },
        { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
        { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
    },
}
