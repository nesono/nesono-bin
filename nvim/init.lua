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

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- Enable 24-bit terminal colors
vim.opt.termguicolors = true


require("toggleterm").setup({
  open_mapping = [[<C-t>]],
  direction = "float",
  float_opts = {
    border = "curved",
    winblend = 5,
  }
})


-- Mason
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
    -- ["rust_analyzer"] = function ()
    --     require("rust-tools").setup {}
    -- end
}
vim.api.nvim_set_keymap('n', '<leader>m', ':Mason<cr>', {noremap = true, silent = true})
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
            vim.api.nvim_buf_set_keymap(0, 'n', '<leader>si', '<cmd>lua vim.lsp.buf.implementation()<cr>', {noremap = true})
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
vim.api.nvim_set_keymap('n', '<leader>tl', ':ToggleTermSendVisualLines<cr>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>ts', ':ToggleTermSendVisualSelection<cr>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>tc', ':ToggleTermSendCurrentLine<cr>', {noremap = true, silent = true})

-- Copilot
vim.api.nvim_set_keymap('n', '<leader>ct', "<cmd>lua require(\"copilot.suggestion\").toggle_auto_trigger()<cr>", {noremap = true, silent = true})

-- NvimTree
vim.api.nvim_set_keymap('n', '<leader>bb', ':NvimTreeToggle<cr>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>bf', ':NvimTreeFindFileToggle<cr>', {noremap = true})

-- Common Short Cuts
vim.api.nvim_set_keymap('n', '<F5>', ':nohls<cr>', {noremap = true})
vim.api.nvim_set_keymap('n', '<F6>', ':call ToggleQuickfixList()<cr>', {noremap = true})

-- Telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- Autoformatting
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
})
