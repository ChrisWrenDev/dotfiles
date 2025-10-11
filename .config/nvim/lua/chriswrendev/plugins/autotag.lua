return {
    "windwp/nvim-ts-autotag",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
        require("nvim-ts-autotag").setup({
            opts = {
                enable_close = true,  -- Auto close tags
                enable_rename = true, -- Rename matching tags when you edit the opening tag
                enable_close_on_slash = true, -- Auto close when typing `</`
            },
        })
    end,
}
