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

-- Autoformatting
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
})
