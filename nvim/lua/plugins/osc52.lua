return {
	"ojroques/nvim-osc52",
	config = function()
		vim.keymap.set("n", "<leader>y", require("osc52").copy_operator, { expr = true })
		vim.keymap.set("n", "<leader>yy", "<leader>c_", { remap = true })
		vim.keymap.set("v", "<leader>y", require("osc52").copy_visual)
	end,
}
