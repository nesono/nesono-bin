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
		local base_codecompanion_cfg = {
			extensions = {
				mcphub = {
					callback = "mcphub.extensions.codecompanion",
					opts = {
						make_vars = true,
						make_slash_commands = true,
						show_result_in_chat = true
					}
				}
			}
		}
		if openai_api_key then
			base_codecompanion_cfg.strategies = {
				chat = { adapter = "openai" },
				inline = { adapter = "openai" },
				cmd = { adapter = "openai" },
				agent = { adapter = "openai" },
			}
		end
		require("codecompanion").setup(base_codecompanion_cfg)
		vim.keymap.set("n", "<leader>cc", ":CodeCompanionChat Toggle<cr>", { desc = "Open CodeCompanion Chat" })
		vim.keymap.set({'o', 'x'}, "<leader>cc", ":CodeCompanion<cr>", { desc = "CodeCompanion on selection" })
		vim.keymap.set({'n', 'o', 'x'}, "<leader>ca", ":CodeCompanionActions<cr>", { desc = "CodeCompanion Actions" })
	end,
}
