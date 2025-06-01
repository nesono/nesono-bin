return {
	"olimorris/codecompanion.nvim",
	opts = {},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		{ "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } },
	},
	config = function()
		require("codecompanion").setup()
		vim.keymap.set("n", "<leader>cc", ":CodeCompanionChat Toggle<cr>")
		vim.keymap.set("n", "<leader>cp", ":CodeCompanion<cr>")
		vim.keymap.set("n", "<leader>ca", ":CodeCompanionActions<cr>")
	end,
}
