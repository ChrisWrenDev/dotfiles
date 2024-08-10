return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup()

		vim.keymap.set("n", "ha", function()
			harpoon:list():add()
		end)

		vim.keymap.set("n", "hr", function()
			harpoon:list():remove()
		end)

		vim.keymap.set("n", "hn", function()
			harpoon:list():next()
		end)
		vim.keymap.set("n", "hp", function()
			harpoon:list():prev()
		end)

		vim.keymap.set("n", "hm", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end)

		local keys = { "h1", "h2", "h3", "h4" }
		local leader_keys = { "<leader>h1", "<leader>h2", "<leader>h3", "<leader>h4" }

		for i, key in ipairs(keys) do
			vim.keymap.set("n", key, function()
				harpoon:list():select(i)
			end)
		end

		for i, key in ipairs(leader_keys) do
			vim.keymap.set("n", key, function()
				harpoon:list():replace_at(i)
			end)
		end
	end,
}
