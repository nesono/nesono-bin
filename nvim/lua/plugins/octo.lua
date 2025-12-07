return {
	"pwntester/octo.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  config = function ()
	  require('octo').setup({
		  picker = "snacks",
	  })
	vim.api.nvim_set_keymap('n', '<leader>oo', ':Octo pr open<cr>', {noremap = true, silent = true})
	vim.api.nvim_set_keymap('n', '<leader>ol', ':Octo pr list<cr>', {noremap = true, silent = true})
	vim.api.nvim_set_keymap('n', '<leader>os', ':Octo search repo:fernride/talos_project is:open is:pr label:n4_image_manifest_change -is:draft base:main<cr>', {noremap = true, silent = true})
	vim.api.nvim_set_keymap('n', '<leader>or', ':Octo review start<cr>', {noremap = true, silent = true})
  end
}
