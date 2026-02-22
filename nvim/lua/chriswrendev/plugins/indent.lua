return {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPre", "BufNewFile" },
    main = "ibl",
    opts = {
        indent = {
            char = "│", -- "┊"
        },
        scope = {
            enabled = true, -- disable if distracting
            show_start = false,
            show_end = false,
            highlight = "Function", -- "CursorLine" for active scope only
        },
        exclude = {
            filetypes = {
                "help",
                "alpha",
                "dashboard",
                "lazy",
                "mason",
                "notify",
                "trouble",
                "toggleterm",
                "oil",
            },
            buftypes = { "terminal", "nofile" },
        },
    },
}
