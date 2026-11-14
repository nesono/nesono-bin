return {
	"tpope/vim-fugitive",
	cmd = { "Git", "G" },
	init = function()
		-- Register global mappings before Fugitive or Diffview is loaded.
		vim.keymap.set("n", "<leader>cc", "<Cmd>Git commit <bar> wincmd J<CR>", {
			silent = true,
			desc = "Commit staged changes",
		})
		vim.keymap.set("n", "<leader>ca", "<Cmd>Git commit --amend <bar> wincmd J<CR>", {
			silent = true,
			desc = "Amend the last commit",
		})
		vim.keymap.set("n", "<leader>c<Space>", ":Git commit ", {
			desc = "Populate command line with :Git commit ",
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "fugitive",
			callback = function(ev)
				local opts = { buffer = ev.buf, silent = true }

				vim.keymap.set(
					"n",
					"cc",
					"<Cmd>Git commit <bar> wincmd J<CR>",
					vim.tbl_extend("force", opts, { desc = "Commit staged changes" })
				)

				vim.keymap.set(
					"n",
					"ca",
					"<Cmd>Git commit --amend <bar> wincmd J<CR>",
					vim.tbl_extend("force", opts, { desc = "Amend the last commit" })
				)

				vim.keymap.set(
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
