return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		{ "nvim-telescope/telescope-file-browser.nvim" },
	},
	config = function()
		require("telescope").setup({
			-- 	pickers = {
			-- 		find_files = {
			-- 			theme = "ivy",
			-- 		},
			-- 	},
		})

		require("telescope").load_extension("fzf")

		vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, { desc = "Find files" })
		vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep, { desc = "Live grep" })
		vim.keymap.set("n", "<leader>fb", require("telescope.builtin").buffers, { desc = "List buffers" })
		vim.keymap.set("n", "<leader>fh", require("telescope.builtin").help_tags, { desc = "Help tags" })
		vim.keymap.set(
			"n",
			"<leader>fl",
			require("telescope.builtin").current_buffer_fuzzy_find,
			{ desc = "Fuzzy find in current buffer" }
		)
		vim.keymap.set("n", "<leader>fc", require("telescope.builtin").git_commits, { desc = "Git commits" })
		vim.keymap.set("n", "<leader>fs", require("telescope.builtin").treesitter, { desc = "Treesitter symbols" })
		vim.keymap.set(
			"n",
			"<leader>ft",
			require("telescope").extensions.file_browser.file_browser,
			{ desc = "File browser" }
		)
		vim.keymap.set("n", "<leader>fn", function()
			require("telescope.builtin").find_files({
				cwd = vim.fn.stdpath("config"),
			})
		end)
		vim.keymap.set("n", "<leader>fp", function()
			require("telescope.builtin").find_files({
				cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy"),
			})
		end)
		vim.keymap.set("n", "<leader>fk", require("telescope.builtin").keymaps, { desc = "Keymaps" })
		vim.keymap.set("n", "<leader>fr", require("telescope.builtin").oldfiles, { desc = "Recent files" })
	end,
}
