return {
    {
        -- Pick up environment changes when enter a project
        "direnv/direnv.vim",
        event = "VeryLazy",
    },
    {
        "mbbill/undotree",
        keys = {
            { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Undotree" },
        },
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {},
    },
}
