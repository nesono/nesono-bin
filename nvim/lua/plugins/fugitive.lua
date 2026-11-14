return {
	"tpope/vim-fugitive",
	cmd = { "Git", "G" },
	init = function()
		-- Register global mappings before Fugitive or Diffview is loaded.
		require("config.usage").map("n", "<leader>cc", "<Cmd>Git commit <bar> wincmd J<CR>", {
			silent = true,
			desc = "Commit staged changes",
		})
		require("config.usage").map("n", "<leader>ca", "<Cmd>Git commit --amend <bar> wincmd J<CR>", {
			silent = true,
			desc = "Amend the last commit",
		})
		require("config.usage").map("n", "<leader>c<Space>", ":Git commit ", {
			desc = "Populate command line with :Git commit ",
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "fugitive",
			callback = function(ev)
				local opts = { buffer = ev.buf, silent = true }

				require("config.usage").map(
					"n",
					"cc",
					"<Cmd>Git commit <bar> wincmd J<CR>",
					vim.tbl_extend("force", opts, { desc = "Commit staged changes" })
				)

				require("config.usage").map(
					"n",
					"ca",
					"<Cmd>Git commit --amend <bar> wincmd J<CR>",
					vim.tbl_extend("force", opts, { desc = "Amend the last commit" })
				)

				require("config.usage").map(
					"n",
					"c<Space>",
					":Git commit ",
					vim.tbl_extend("force", opts, {
						desc = "Populate command line with :Git commit ",
					})
				)
			end,
		})
	end,
}
