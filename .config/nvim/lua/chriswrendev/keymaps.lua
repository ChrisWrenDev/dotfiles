local map = vim.keymap.set
local opts = { noremap = true, silent = true }

vim.api.nvim_create_user_command("E", "Oil", { desc = "Open Oil instead of NetRW" })

-- center screen
map("n", "<C-d>", "<C-d>zz", opts)
map("n", "<C-u>", "<C-u>zz", opts)
map("n", "n", "nzzzv", opts)
map("n", "N", "Nzzzv", opts)
map("n", "G", "Gzzzv", opts)

-- remap for dealing with word wrap
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- remove mapping
map({ "n", "x" }, "Q", "<nop>")
map({ "n", "x" }, "<Space>", "<nop>")

-- because im lazy
map({ "n", "v" }, "<S-h>", "^", opts)
map({ "n", "v" }, "<S-l>", "$", opts)
map("n", "<leader><ESC>", "<cmd>qa<CR>", opts)

map("n", "<C-s>", "<cmd>w<CR>", { desc = "general save file" })

-- move code up and down
map("n", "<M-j>", ":m+<CR>", opts)          -- move line down
map("n", "<M-k>", ":m-2<CR>", opts)         -- move line up
map("x", "<M-j>", ":m '>+1<CR>gv=gv", opts) -- move code block down
map("x", "<M-k>", ":m '<-2<CR>gv=gv", opts) -- move code block up

-- better indents
map("x", "<", "<gv", opts)
map("x", ">", ">gv", opts)

-- formatting
map("n", "<leader>fm", function()
    require("conform").format { lsp_fallback = true }
end, { desc = "general format file" })

-- buffer
map("n", "<leader>b", "<cmd>enew<CR>", { desc = "buffer new" })
map("n", "<tab>", "<cmd>bnext<CR>", { desc = "buffer goto next" })
map("n", "<S-tab>", "<cmd>bprev<CR>", { desc = "buffer goto prev" })
map("n", "<leader>x", "<cmd>bdelete<CR>", { desc = "buffer close" })

-- navigate around quickfix list
map("n", "<C-n>", "<cmd>cnext<CR>", opts)
map("n", "<C-p>", "<cmd>cprev<CR>", opts)

-- avoid vim register for some operations
map("n", "x", [["_x]], opts)
map("x", "p", [["_dP]], opts)
map("v", "<backspace>", '"_d', opts)
map("n", "<backspace>", '"_dh', opts)
map("n", "<leader>Y", [["+Y]], opts)               -- copy current line to system clipboard
map("n", "<leader>vp", "`[v`]", opts)              -- reselect pasted text
map({ "n", "x", "v" }, "<leader>y", [["+y]], opts) -- copy to system clipboard
map({ "n", "x" }, "<leader>p", [["+p]], opts)      -- paste from system clipboard
map("n", "YY", "va{Vy", opts)

-- copy to clipboard
-- map("v", "<leader>y", '"+y', opts)
map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "general copy whole file" })

map("n", "<S-Tab>", "<cmd>tabNext<CR>") -- cycle between tabs

-- split resize
map("n", "<C-Up>", ":resize -2<CR>", opts)
map("n", "<C-Down>", ":resize +2<CR>", opts)
map("n", "<C-Left>", ":vertical resize -2<CR>", opts)
map("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- split navigation(commented couz of tmux-vim-navigator plugin)
-- map("n", "<C-h>", "<C-w>h", opts)
-- map("n", "<C-j>", "<C-w>j", opts)
-- map("n", "<C-k>", "<C-w>k", opts)
-- map("n", "<C-l>", "<C-w>l", opts)

-- term mode
map("t", "<esc>", "<C-\\><C-n>", opts) -- go back to normal mode with <esc> on terminal mode

-- search and replace
map("n", "<leader>sr", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], opts)

-- Comment
map("n", "<leader>/", "gcc", { desc = "toggle comment", remap = true })
map("v", "<leader>/", "gc", { desc = "toggle comment", remap = true })

-- telescope
map("n", "<leader>fw", "<cmd>Telescope live_grep<CR>", { desc = "telescope live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "telescope find buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "telescope help page" })
map("n", "<leader>fm", "<cmd>Telescope marks<CR>", { desc = "telescope find marks" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>", { desc = "telescope find oldfiles" })
map("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "telescope find in current buffer" })
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "telescope find files" })
map(
    "n",
    "<leader>fa",
    "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>",
    { desc = "telescope find all files" }
)

map("n", "<leader>gc", "<cmd>Telescope git_commits<CR>", { desc = "telescope git commits" })
map("n", "<leader>gs", "<cmd>Telescope git_status<CR>", { desc = "telescope git status" })
map("n", "<leader>pt", "<cmd>Telescope terms<CR>", { desc = "telescope pick hidden term" })

-- whichkey
map("n", "<leader>wK", "<cmd>WhichKey <CR>", { desc = "whichkey all keymaps" })

map("n", "<leader>wk", function()
    vim.cmd("WhichKey " .. vim.fn.input "WhichKey: ")
end, { desc = "whichkey query lookup" })

-- rust analyzer
-- vim.keymap.set("n", "<leader>raf", function()
--   require("chriswrendev.utils.ra_toggle").fast()
-- end, { desc = "Rust Analyzer: fast mode" })
--
-- vim.keymap.set("n", "<leader>rau", function()
--   require("chriswrendev.utils.ra_toggle").full()
-- end, { desc = "Rust Analyzer: full (macros)" })
