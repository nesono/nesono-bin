return {
	"sindrets/diffview.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"tpope/vim-fugitive",
	},
	cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
	config = function()
		require("diffview").setup({ watch_index = true })
		require("config.usage").map("n", "<leader>dd", "<cmd>DiffviewOpen<cr>", {
			desc = "Git diff",
		})
		require("config.usage").map("n", "<leader>dp", "<cmd>DiffviewOpen origin/main...HEAD<cr>", {
			desc = "PR diff (merge-base)",
		})
		require("config.usage").map("n", "<leader>df", "<cmd>DiffviewFileHistory %<cr>", {
			desc = "Current file git history",
		})
		require("config.usage").map("n", "<leader>dh", function()
			local keys = vim.api.nvim_replace_termcodes(":DiffviewFileHistory ", true, false, true)
			vim.fn.feedkeys(keys, "n")
		end, { desc = "Diffview (prompt)" })
		require("config.usage").map("n", "<leader>dc", "<cmd>DiffviewClose<cr>", {
			desc = "Close diff view",
		})
	end,
}
