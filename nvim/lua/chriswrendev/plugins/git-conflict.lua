return {
    "akinsho/git-conflict.nvim",
    event = "VeryLazy", -- auto detect conflicts
    opts = {
        default_mappings = false, -- defined my own
        disable_diagnostics = true, -- conflicts already show enough noise
        highlights = {
            incoming = "DiffAdd",
            current = "DiffChange", -- DiffText
        },
    },
    keys = {
        { "<leader>co", "<cmd>GitConflictChooseOurs<cr>", desc = "Conflict: choose ours" },
        { "<leader>ct", "<cmd>GitConflictChooseTheirs<cr>", desc = "Conflict: choose theirs" },
        { "<leader>cb", "<cmd>GitConflictChooseBoth<cr>", desc = "Conflict: choose both" },
        { "<leader>cn", "<cmd>GitConflictChooseNone<cr>", desc = "Conflict: choose none" },

        { "]x", "<cmd>GitConflictNextConflict<cr>", desc = "Next conflict" },
        { "[x", "<cmd>GitConflictPrevConflict<cr>", desc = "Prev conflict" },
    },
}
