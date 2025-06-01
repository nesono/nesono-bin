return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup {}
	vim.api.nvim_set_keymap('n', '<leader>bb', ':NvimTreeToggle<cr>', {noremap = true})
	vim.api.nvim_set_keymap('n', '<leader>bf', ':NvimTreeFindFile<cr>', {noremap = true})
  end,
}
