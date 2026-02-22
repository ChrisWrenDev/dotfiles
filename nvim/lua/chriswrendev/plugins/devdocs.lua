return {
    "maskudo/devdocs.nvim",
    cmd = { "DevDocs" },
    dependencies = {
        "folke/snacks.nvim",
    },
    keys = {
        {
            "<leader>ho",
            mode = "n",
            "<cmd>DevDocs get<cr>",
            desc = "Get Devdocs",
        },
        {
            "<leader>hi",
            mode = "n",
            "<cmd>DevDocs install<cr>",
            desc = "Install Devdocs",
        },
    },
    -- NOTE: handled in Treesitter
    --  opts = {
    --      ensure_installed = {
    --          "go",
    --          "http",
    --          -- "css",
    --          -- "javascript",
    --          "lua~5.1",
    --          "rust",
    --      },
    --  },
}
-- NOTE: Plugin requires jq, curl and pandoc
