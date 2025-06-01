return {
	"olimorris/codecompanion.nvim",
	opts = {},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		vim.api.nvim_set_keymap('n', '<leader>cc', ':CodeCompanionChat Toggle<cr>', {noremap = true})
		vim.api.nvim_set_keymap('n', '<leader>cp', ':CodeCompanion<cr>', {noremap = true})
		vim.api.nvim_set_keymap('n', '<leader>ca', ':CodeCompanionActions<cr>', {noremap = true})
	end
}
