-- Needs to be set before we load lazy.lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.lazy")

-- Enable filetype detection, plugins, and indenting
vim.api.nvim_exec(
	[[
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
]],
	false
)

vim.cmd.colorscheme("habamax")

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
		rust = { "rustfmt" },
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
vim.api.nvim_set_keymap("n", "<leader>/", ":nohls<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>nn", ":set number!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>nr", ":set relativenumber!<cr>", { noremap = true })

-- For CodeCopmanion

-- Mason
require("mason").setup()

vim.api.nvim_set_keymap("n", "<leader>dh", ":lua vim.diagnostic.disable()<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>ds", ":lua vim.diagnostic.enable()<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>df", ":lua vim.diagnostic.open_float()<cr>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<leader>m", ":Mason<cr>", { noremap = true, silent = true })
require("dapui").setup()
function _dapui_toggle()
	require("dapui").toggle()
end
vim.api.nvim_set_keymap("n", "<leader>dd", "<cmd>lua _dapui_toggle()<cr>", { noremap = true, silent = true })

-- LSP
-- C-]: Symbol under cursor
-- K:   Documentation: K (twice to jump into popup)
-- C-w ]: Split + under cursor
-- gO: show symbols
-- gra: code actions menu
-- grn rename symbol
-- gri go to implementation (C/C++)

-- Lazy
vim.api.nvim_set_keymap("n", "<leader>ll", ":Lazy<cr>", { noremap = true })

-- Autoformatting
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})
