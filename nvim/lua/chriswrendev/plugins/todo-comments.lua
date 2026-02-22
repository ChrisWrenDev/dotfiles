return {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
        {
            "tn",
            function()
                require("todo-comments").jump_next()
            end,
            desc = "Next todo comment",
            mode = "n",
        },
        {
            "tp",
            function()
                require("todo-comments").jump_prev()
            end,
            desc = "Prev todo comment",
            mode = "n",
        },
        {
            "ts",
            ":lua Snacks.picker.todo_comments()<CR>",
            desc = "Search todo comments",
            mode = "n",
        },
    },
    opts = {
        keywords = {
            FIX = { icon = " ", color = "#FF2D00", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
            TODO = { icon = " ", color = "#FF8C00" },
            HACK = { icon = " ", color = "#3498DB", alt = { "MYTH" } },
            WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
            NOTE = { icon = " ", color = "#98C379", alt = { "INFO", "HINT" } },
        },
    },
}
