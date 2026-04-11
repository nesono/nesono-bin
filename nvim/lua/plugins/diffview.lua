return {
	"sindrets/diffview.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
	config = function()
		require("diffview").setup({ watch_index = true })
		vim.keymap.set("n", "<leader>dp", "<cmd>DiffviewOpen origin/main...HEAD<cr>", {
			desc = "PR diff (merge-base)",
		})
		vim.keymap.set("n", "<leader>df", "<cmd>DiffviewFileHistory %<cr>", {
			desc = "Current file git history",
		})
		vim.keymap.set("n", "<leader>dd", function()
			local keys = vim.api.nvim_replace_termcodes(":DiffviewFileHistory ", true, false, true)
			vim.fn.feedkeys(keys, "n")
		end, { desc = "Diffview (prompt)" })
		vim.keymap.set("n", "<leader>dc", "<cmd>DiffviewClose<cr>", {
			desc = "Close diff view",
		})
	end,
}
