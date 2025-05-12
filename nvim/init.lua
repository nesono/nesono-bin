-- Needs to be set before we load lazy.lua
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

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
  set autoread
  au CursorHold * checktime
]], false)

vim.cmd.colorscheme('habamax')

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- Enable 24-bit terminal colors
vim.opt.termguicolors = true


require("toggleterm").setup({
  open_mapping = [[<C-h>]],
  direction = "float",
  float_opts = {
    border = "curved",
    winblend = 5,
  }
})

-- Comment shortcuts
-- `gcc` to comment out a line
-- `gc` to comment out the target of a motion (visual mode)

-- Conform
require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff" },
    rust = { "rustfmt"},
    javascript = { "prettier" },
	c = { "clang-format" },
	cpp = { "clang-format" },
	haskell = { "ormolu" },
	java = { "google-java-format" },
	sh = { "shellcheck" },
	bash = { "shellcheck" },
  },
})

-- Common Short Cuts
vim.api.nvim_set_keymap('n', '<leader>//', ':nohls<cr>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>nn', ':set number!<cr>', {noremap = true})

-- For CodeCopmanion
vim.api.nvim_set_keymap('n', '<leader>cc', ':CodeCompanionChat<cr>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>cp', ':CodeCompanion<cr>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>ca', ':CodeCompanionActions<cr>', {noremap = true})

-- For Octo
vim.api.nvim_set_keymap('n', '<leader>oo', ':Octo pr open<cr>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>ol', ':Octo pr list<cr>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>os', ':Octo search repo:fernride/talos_project is:open is:pr label:n4_image_manifest_change -is:draft base:main<cr>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>or', ':Octo review start<cr>', {noremap = true, silent = true})

-- Mason
require("mason").setup()

-- Git blame`
require('blame').setup({
	date_format = '%Y-%m-%d',
})
vim.api.nvim_set_keymap('n', '<leader>dh', ':lua vim.diagnostic.disable()<cr>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>ds', ':lua vim.diagnostic.enable()<cr>', {noremap = true, silent = true})

vim.api.nvim_set_keymap('n', '<leader>gb', ':BlameToggle<cr>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>m', ':Mason<cr>', {noremap = true, silent = true})
require('nvim-tree').setup({
	view = { adaptive_size = true },
})
require("dapui").setup()
function _dapui_toggle()
    require("dapui").toggle()
end
vim.api.nvim_set_keymap('n', '<leader>dd', '<cmd>lua _dapui_toggle()<cr>', {noremap = true, silent = true})

-- LSP
-- Symbol under cursor: C-]
-- Documentation: K (twice to jump into popup)
-- Split + under cursor: C-W ]
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client.supports_method('textDocument/rename') then
            vim.api.nvim_buf_set_keymap(0, 'n', '<leader>sr', '<cmd>lua vim.lsp.buf.rename()<cr>', {noremap = true})
        end
        if client.supports_method('textDocument/implementation') then
            vim.api.nvim_buf_set_keymap(0, 'n', '<leader>sc', '<cmd>lua vim.lsp.buf.implementation()<cr>', {noremap = true})
        end
        if client.supports_method('textDocument/definition') then
            vim.api.nvim_buf_set_keymap(0, 'n', '<leader>sd', '<cmd>lua vim.lsp.buf.definition()<cr>', {noremap = true})
        end
        if client.supports_method('textDocument/references') then
            vim.api.nvim_buf_set_keymap(0, 'n', '<leader>sl', '<cmd>lua vim.lsp.buf.references()<cr>', {noremap = true})
        end
        if client.supports_method('callHierarchy/incomingCalls') then
            vim.api.nvim_buf_set_keymap(0, 'n', '<leader>si', '<cmd>lua vim.lsp.buf.incoming_calls()<cr>', {noremap = true})
        end
        if client.supports_method('callHierarchy/outgoingCalls') then
            vim.api.nvim_buf_set_keymap(0, 'n', '<leader>so', '<cmd>lua vim.lsp.buf.outgoing_calls()<cr>', {noremap = true})
        end
    end,
})
vim.api.nvim_set_keymap('n', '<leader>sf', '<cmd>lua vim.lsp.buf.code_action({"quickfix"})<cr>', {noremap = true})

-- Nvim 
vim.api.nvim_set_keymap('n', '<leader>ne', ':e $MYVIMRC<cr>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>nr', ':source $MYVIMRC<cr>', {noremap = true})

-- Lazy
vim.api.nvim_set_keymap('n', '<leader>ll', ':Lazy<cr>', {noremap = true})

-- Toggleterm
local Terminal = require('toggleterm.terminal').Terminal
local shell = Terminal:new({count = 1})
function _shell_toggle()
  shell:toggle()
end
vim.api.nvim_set_keymap('n', '<leader>tt', '<cmd>lua _shell_toggle()<cr>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>tm', ':TermSelect<cr>', {noremap = true, silent = true})

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
vim.api.nvim_set_keymap('n', '<leader>tl', ':ToggleTermSendVisualLines<cr>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>ts', ':ToggleTermSendVisualSelection<cr>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>tc', ':ToggleTermSendCurrentLine<cr>', {noremap = true, silent = true})

-- NvimTree
vim.api.nvim_set_keymap('n', '<leader>bb', ':NvimTreeToggle<cr>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>bf', ':NvimTreeFindFile<cr>', {noremap = true})

-- Telescope
local telescope_builtin = require('telescope.builtin')
-- vim.keymap.set('n', '<leader>ff', telescope_builtin.find_files, { desc = 'Telescope find files' })
vim.api.nvim_set_keymap('n', '<leader>ff', ':Telescope find_files hidden=true no_ignore=true<cr>', {noremap = true})
vim.keymap.set('n', '<leader>fg', telescope_builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', telescope_builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', telescope_builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>fc', telescope_builtin.git_commits, { desc = 'Telescope git commits' })
vim.keymap.set('n', '<leader>ft', telescope_builtin.treesitter, { desc = 'Telescope treesitter' })

-- Autoformatting
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
})
