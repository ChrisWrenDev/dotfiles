return {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",
    event = "VeryLazy", -- loads after colorschmeme
    dependencies = {
        "SmiteshP/nvim-navic",
        "nvim-tree/nvim-web-devicons",
    },
    keys = {
        {
            "<leader>bt",
            function()
                require("barbecue.ui").toggle()
            end,
            desc = "Toggle Barbecue",
        },
    },
    opts = {
        kinds = require("chriswrendev.utils.kinds").icons,
    },
}
