return {
    "bloznelis/before.nvim",
    event = "BufReadPre", -- or remove this to load only on keypress
    opts = {
        history_size = 60,
        -- history_wrap_enabled = true, -- optional
    },
    keys = {
        {
            "le",
            function()
                require("before").jump_to_last_edit()
            end,
            desc = "Jump to previous entry in the edit history",
        },
        {
            "ne",
            function()
                require("before").jump_to_next_edit()
            end,
            desc = "Jump to next entry in the edit history",
        },
        {
            "qe",
            function()
                require("before").show_edits_in_quickfix()
            end,
            desc = "Look for previous edits in quickfix list",
        },
        {
            "te",
            function()
                require("before").show_edits_in_telescope()
            end,
            desc = "Look for previous edits in telescope",
        },
    },
}
