return {
    "folke/persistence.nvim",
    event = "BufReadPre", -- load early enough to restore buffers
    opts = {
        dir = vim.fn.stdpath("state") .. "/sessions/",
        options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals" },
        pre_save = nil,
    },
    keys = {
        {
            "<leader>qs",
            function()
                require("persistence").load()
            end,
            desc = "Restore session",
        },
        {
            "<leader>qS",
            function()
                require("persistence").select()
            end,
            desc = "Select session",
        },
        {
            "<leader>ql",
            function()
                require("persistence").load({ last = true })
            end,
            desc = "Restore last session",
        },
        {
            "<leader>qd",
            function()
                require("persistence").stop()
            end,
            desc = "Disable session saving",
        },
    },
}
