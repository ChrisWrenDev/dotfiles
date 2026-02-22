return {
    "toppair/peek.nvim",
    build = "deno task --quiet build:fast",
    keys = {
        {
            "<leader>md",
            function()
                local peek = require("peek")
                if peek.is_open() then
                    peek.close()
                else
                    peek.open()
                end
            end,
            desc = "Markdown Preview",
            ft = "markdown",
        },
    },
    config = function()
        require("peek").setup()
    end,
}
