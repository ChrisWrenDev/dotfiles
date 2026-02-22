return {
    "alexghergh/nvim-tmux-navigation",
    keys = (function()
        return {
            {
                "<C-h>",
                function()
                    require("nvim-tmux-navigation").NvimTmuxNavigateLeft()
                end,
                desc = "Navigate left (tmux)",
            },
            {
                "<C-j>",
                function()
                    require("nvim-tmux-navigation").NvimTmuxNavigateDown()
                end,
                desc = "Navigate down (tmux)",
            },
            {
                "<C-k>",
                function()
                    require("nvim-tmux-navigation").NvimTmuxNavigateUp()
                end,
                desc = "Navigate up (tmux)",
            },
            {
                "<C-l>",
                function()
                    require("nvim-tmux-navigation").NvimTmuxNavigateRight()
                end,
                desc = "Navigate right (tmux)",
            },
        }
    end)(),
}
-- Check commands don't override tmux
-- Check tmux config allows pane switching
