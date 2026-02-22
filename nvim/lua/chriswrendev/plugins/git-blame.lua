return {
    "f-person/git-blame.nvim",
    event = "VeryLazy",
    opts = {
        enabled = false,
    },
    keys = {
        { "<leader>gb", "<cmd>GitBlameToggle<cr>", desc = "Toggle git blame" },
    },
}
