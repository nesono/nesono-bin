vim.g.mapleader = ' '

require("config.lazy")

-- Enable filetype detection, plugins, and indenting
vim.api.nvim_exec([[
  syntax enable
  filetype on
  filetype plugin on
  filetype indent on
  set hidden
  set number
  set tabstop=4
  set shiftwidth=0
]], false)

vim.cmd.colorscheme('molokai')

require("copilot").setup(options)
require("toggleterm").setup({
  open_mapping = [[<C-t>]],
  direction = "float",
  float_opts = {
    border = "curved",
    winblend = 5,
  }
})

require("mason").setup()
require("mason-lspconfig").setup()
require("mason-lspconfig").setup_handlers {
	-- The first entry (without a key) will be the default handler
	-- and will be called for each installed server that doesn't have
	-- a dedicated handler.
	function (server_name) -- default handler (optional)
		require("lspconfig")[server_name].setup {}
	end,
	-- Next, you can provide a dedicated handler for specific servers.
	-- For example, a handler override for the `rust_analyzer`:
	["rust_analyzer"] = function ()
		require("rust-tools").setup {}
	end
}
vim.api.nvim_set_keymap('n', '<leader>m', ':Mason<cr>', {noremap = true, silent = true})
require("dapui").setup()
function _dapui_toggle()
	require("dapui").toggle()
end
vim.api.nvim_set_keymap('n', '<leader>d', '<cmd>lua _dapui_toggle()<cr>', {noremap = true, silent = true})


vim.api.nvim_set_keymap('n', '<leader>e', ':e $MYVIMRC<cr>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>r', ':source $MYVIMRC<cr>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>l', ':Lazy<cr>', {noremap = true})

local Terminal = require('toggleterm.terminal').Terminal
local lazygit = Terminal:new({count = 1})
function _shell_toggle()
  lazygit:toggle()
end
vim.api.nvim_set_keymap('n', '<leader>tt', '<cmd>lua _shell_toggle()<cr>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>ts', ':TermSelect<cr>', {noremap = true, silent = true})

local Terminal = require('toggleterm.terminal').Terminal
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

vim.api.nvim_set_keymap('n', '<F2>', ':NvimTreeToggle<cr>', {noremap = true})
vim.api.nvim_set_keymap('n', '<F3>', ':NvimTreeFindFile<cr>', {noremap = true})
vim.api.nvim_set_keymap('n', '<F5>', ':nohls<cr>', {noremap = true})
vim.api.nvim_set_keymap('n', '<F6>', ':call ToggleQuickfixList()<cr>', {noremap = true})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

