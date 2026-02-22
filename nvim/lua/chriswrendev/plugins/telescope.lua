return {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "mfussenegger/nvim-dap",
        {
            "nvim-telescope/telescope-dap.nvim",
            config = function()
                require("telescope").load_extension("dap")
            end,
        },
    },
    keys = {
        { "<leader>fdc", "<cmd>Telescope dap commands<cr>", desc = "DAP: Commands" },
        { "<leader>fdb", "<cmd>Telescope dap list_breakpoints<cr>", desc = "DAP: Breakpoints" },
        { "<leader>fdv", "<cmd>Telescope dap variables<cr>", desc = "DAP: Variables" },
        { "<leader>fdf", "<cmd>Telescope dap frames<cr>", desc = "DAP: Frames" },
    },
    config = function()
        require("telescope").setup({})
    end,
}
