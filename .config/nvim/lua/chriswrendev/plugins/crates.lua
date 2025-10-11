return { {
    'saecki/crates.nvim',
    event = { "BufRead Cargo.toml" },
    config = function()
        require('crates').setup()
    end,
},
    {
        "vuki656/package-info.nvim",
        requires = "MunifTanjim/nui.nvim",
        event = { "BufRead package.json" },
        config = function()
            require("package-info").setup({
                hide_up_to_date = true,
                colors = {
                    up_to_date = "#6A9955",
                    outdated   = "#D19A66",
                },
            })
        end
    }
}
