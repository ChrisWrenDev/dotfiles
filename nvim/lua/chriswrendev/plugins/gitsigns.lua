return {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = {
        signs = {
            add = { text = " +" },
            change = { text = " " },
            delete = { text = " " },
            untracked = { text = "┆" },
            topdelete = { text = " " },
            changedelete = { text = " " },
        },

        on_attach = function(bufnr)
            local gs = require("gitsigns")

            local function map(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, {
                    buffer = bufnr,
                    silent = true,
                    noremap = true,
                    desc = desc,
                })
            end

            -- normal mode
            map("n", "gn", gs.next_hunk, "Git: Next hunk")
            map("n", "gN", gs.prev_hunk, "Git: Prev hunk")
            map("n", "<leader>gb", gs.blame_line, "Git: Blame line")
            map("n", "<leader>gd", gs.toggle_deleted, "Git: Toggle deleted")
            map("n", "<leader>gw", gs.toggle_word_diff, "Git: Toggle word diff")
            map("n", "<leader>go", "<cmd>Gitsigns<CR>", "Git: Options")
            map("n", "<leader>gl", gs.toggle_current_line_blame, "Git: Toggle line blame")

            -- visual mode: operate on selection (normalize range)
            local function get_range()
                local s = vim.fn.line("v")
                local e = vim.fn.line(".")
                if s > e then
                    s, e = e, s
                end
                return { s, e }
            end

            map("v", "gs", function()
                gs.stage_hunk(get_range())
            end, "Git: Stage selection")
            map("v", "gz", function()
                gs.undo_stage_hunk(get_range())
            end, "Git: Undo stage selection")
            map("v", "gr", function()
                gs.reset_hunk(get_range())
            end, "Git: Reset selection")
        end,
    },
}
