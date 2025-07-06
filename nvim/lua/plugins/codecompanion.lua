return {
	"olimorris/codecompanion.nvim",
	opts = {},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		{ "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } },
		{
			"echasnovski/mini.diff",
			config = function()
				local diff = require("mini.diff")
				diff.setup({
					-- Disabled by default
					source = diff.gen_source.none(),
				})
			end,
		},
	},
	config = function()
		local openai_api_key = vim.env.OPENAI_API_KEY
		if openai_api_key then
			require("codecompanion").setup({
				default_adapter = "openai",
				strategies = {
					chat = { adapter = "openai" },
					inline = { adapter = "openai" },
					cmd = { adapter = "openai" },
					agent = { adapter = "openai" },
				},
			})
		else
			require("codecompanion").setup({
			})
		end
		vim.keymap.set("n", "<leader>cc", ":CodeCompanionChat Toggle<cr>")
		vim.keymap.set({'o', 'x'}, "<leader>cc", ":CodeCompanion<cr>")
		vim.keymap.set({'o', 'x'}, "<leader>ca", ":CodeCompanionActions<cr>")
	end,
}
