return {
	"olimorris/codecompanion.nvim",
	opts = {},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		{ "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } },
		"ravitemer/mcphub.nvim",
		-- {
		-- 	"OXY2DEV/markview.nvim",
		-- 	lazy = false,
		-- 	opts = {
		-- 		preview = {
		-- 		filetypes = { "markdown", "codecompanion" },
		-- 		ignore_buftypes = {},
		-- 		},
		-- 	},
		-- },
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
				extensions = {
				-- mcphub = {
				--   callback = "mcphub.extensions.codecompanion",
				--   opts = {
				-- 	make_vars = true,
				-- 	make_slash_commands = true,
				-- 	show_result_in_chat = true
				--   }
				-- }
			  },
			  reference_resolvers = {
				buffer = require("codecompanion.reference_resolvers").buffer,
				visual = require("codecompanion.reference_resolvers").visual,
				file = require("codecompanion.reference_resolvers").file,
			  },
			})
		else
			require("codecompanion").setup({
				extensions = {
				-- mcphub = {
				--   callback = "mcphub.extensions.codecompanion",
				--   opts = {
				-- 	make_vars = true,
				-- 	make_slash_commands = true,
				-- 	show_result_in_chat = true
				--   }
				-- }
			  }
			})
		end
		vim.keymap.set("n", "<leader>cc", ":CodeCompanionChat Toggle<cr>")
		vim.keymap.set("n", "<leader>cp", ":CodeCompanion<cr>")
		vim.keymap.set("n", "<leader>ca", ":CodeCompanionActions<cr>")
	end,
}
