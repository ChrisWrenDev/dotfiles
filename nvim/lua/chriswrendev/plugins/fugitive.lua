return {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gedit", "Gread", "Gwrite", "Gblame" },
    keys = {
        { "<leader>gs", "<cmd>Git<cr>", desc = "Fugitive: Git status" },
        { "<leader>gc", "<cmd>Git commit<cr>", desc = "Fugitive: Commit" },
        { "<leader>gp", "<cmd>Git push<cr>", desc = "Fugitive: Push" },
        { "<leader>gl", "<cmd>Git pull<cr>", desc = "Fugitive: Pull" },
        { "<leader>gd", "<cmd>Gvdiffsplit<cr>", desc = "Fugitive: Diff split" },
    },
}
