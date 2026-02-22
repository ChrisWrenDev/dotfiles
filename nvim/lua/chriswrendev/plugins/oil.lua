return {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
        { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
    },
    opts = {
        default_file_explorer = true,
        delete_to_trash = true,
        skip_confirm_for_simple_edits = true,

        view_options = {
            show_hidden = true,
            is_always_hidden = function(name)
                return name == ".git" or name == "node_modules"
            end,
        },

        keymaps = {
            ["<C-s>"] = false,
            ["<C-h>"] = false,
            ["<C-l>"] = false,
            ["<A-d>"] = "actions.close",
            ["<A-w>"] = "actions.preview",
            ["<C-x>"] = "actions.select_split",
            ["<C-v>"] = "actions.select_vsplit",
        },
    },
}
