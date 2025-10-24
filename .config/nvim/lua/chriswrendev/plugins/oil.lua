return {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
        { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
    },
    opts = {
        delete_to_trash = true,
        default_file_explorer = true,
        skip_confirm_for_simple_edits = true,
        watch_for_changes = true,
        view_options = {
            is_always_hidden = function(name, bufnr)
                return name == ".."
            end,
            show_hidden = true,
        },
        keymaps = {
            ["g?"] = "actions.show_help",
            ["<CR>"] = "actions.select",
            ["l"] = "actions.select",
            ["<C-k>"] = "actions.select_vsplit",
            ["<C-j>"] = "actions.select_split",
            ["<C-t>"] = "actions.select_tab",
            ["<C-p>"] = "actions.preview",
            ["<C-c>"] = "actions.close",
            ["q"] = "actions.close",
            ["esc"] = "actions.close",
            ["r"] = "actions.refresh",
            ["h"] = "actions.parent",
            ["_"] = "actions.open_cwd",
            ["`"] = "actions.cd",
            ["~"] = "actions.tcd",
            ["gs"] = "actions.change_sort",
            ["gx"] = "actions.open_external",
            ["."] = "actions.toggle_hidden",
            ["g\\"] = "actions.toggle_trash",
        },
    },
}
