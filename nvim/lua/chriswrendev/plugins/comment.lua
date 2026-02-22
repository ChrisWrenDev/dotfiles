return {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        {
            "JoosepAlviste/nvim-ts-context-commentstring",
            config = function()
                require("ts_context_commentstring").setup({})
            end,
        },
    },
    opts = function()
        local ts_integration = require("ts_context_commentstring.integrations.comment_nvim")
        return {
            pre_hook = ts_integration.create_pre_hook(),
        }
    end,
}
