return {
    "windwp/nvim-autopairs",
    event = "BufReadPre",
    config = function()
        local autopairs = require("nvim-autopairs")
        -- configure nvim-autopairs
        autopairs.setup({
            check_ts = true,
            ts_config = {
                lua = { "string", "source" },
                javascript = { "string", "template_string" },
                typescript = { "string", "template_string" },
                javascriptreact = { "string", "template_string" },
                typescriptreact = { "string", "template_string" },
                java = false,
            },
        })

        -- import nvim-autopairs completion functionality
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")

        -- import nvim-cmp plugin (completions plugin)
        local cmp = require("cmp")

        -- make autopairs and completion work together
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
}
