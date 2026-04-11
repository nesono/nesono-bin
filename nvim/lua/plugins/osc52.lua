return {
	"ojroques/nvim-osc52",
	config = function()
		vim.keymap.set("n", "<leader>y", require("osc52").copy_operator, { expr = true, desc = "Copy to clipboard" })
		vim.keymap.set("n", "<leader>yy", "<leader>c_", { remap = true, desc = "Copy to clipboard" })
		vim.keymap.set("v", "<leader>y", require("osc52").copy_visual, { desc = "Copy to clipboard" })
	end,
}
