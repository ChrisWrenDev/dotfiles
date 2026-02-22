return {
    "vyfor/cord.nvim",
    build = ":Cord update",
    event = "VeryLazy",
    opts = {
        lsp = {
            show_problem_count = true,
            severity = 3,
        },
        editor = {
            client = "neovim",
        },
        display = {
            show_time = true,
        },
    },
}
