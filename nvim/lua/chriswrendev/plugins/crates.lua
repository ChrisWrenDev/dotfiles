return {
    {
        "saecki/crates.nvim",
        ft = "toml",
        opts = {},
    },
    {
        "vuki656/package-info.nvim",
        ft = "json",
        requires = "MunifTanjim/nui.nvim",
        opts = {
            hide_up_to_date = true,
            colors = {
                up_to_date = "#6A9955",
                outdated = "#D19A66",
            },
        },
    },
}
