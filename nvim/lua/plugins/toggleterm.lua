return {
	'akinsho/toggleterm.nvim',
	config = function()
		require("toggleterm").setup({
		  open_mapping = [[<C-\>]],
		  direction = "float",
		  float_opts = {
			border = "curved",
			winblend = 5,
		  }
		})
		local Terminal = require('toggleterm.terminal').Terminal
		local shell = Terminal:new({count = 1})
		function _shell_toggle()
		  shell:toggle()
		end
		vim.api.nvim_set_keymap('n', '<leader>tt', '<cmd>lua _shell_toggle()<cr>', {noremap = true, silent = true})
		vim.api.nvim_set_keymap('n', '<leader>tm', ':TermSelect<cr>', {noremap = true, silent = true})
		local lazygit = Terminal:new({cmd = "lazygit", count = 2})
		function _lazygit_toggle()
		  lazygit:toggle()
		end
		vim.api.nvim_set_keymap('n', '<leader>tg', '<cmd>lua _lazygit_toggle()<cr>', {noremap = true, silent = true})

		local Terminal = require('toggleterm.terminal').Terminal
		local btop = Terminal:new({cmd = "btop", count = 3})
		function _btop_toggle()
		  btop:toggle()
		end
		vim.api.nvim_set_keymap('n', '<leader>tb', '<cmd>lua _btop_toggle()<cr>', {noremap = true, silent = true})
		vim.api.nvim_set_keymap('n', '<leader>tl', ':ToggleTermSendVisualLines<cr>', {noremap = true, silent = true})
		vim.api.nvim_set_keymap('n', '<leader>ts', ':ToggleTermSendVisualSelection<cr>', {noremap = true, silent = true})
		vim.api.nvim_set_keymap('n', '<leader>tc', ':ToggleTermSendCurrentLine<cr>', {noremap = true, silent = true})
	end
}
