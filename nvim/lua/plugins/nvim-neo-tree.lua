return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
		-- {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window: See `# Preview Mode` for more information
	},
	lazy = false, -- neo-tree will lazily load itself
	---@module "neo-tree"
	---@type neotree.Config?
	opts = {
		-- fill any relevant options here
	},
	config = function(_, opts)
		require("neo-tree").setup(opts)
		vim.api.nvim_set_keymap("n", "<leader>bb", ":Neotree toggle<cr>", { noremap = true, silent = true })
		vim.api.nvim_set_keymap("n", "<leader>bf", ":Neotree reveal<cr>", { noremap = true, silent = true })
	end,
}
