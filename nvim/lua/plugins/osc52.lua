return {
	"ojroques/nvim-osc52",
	config = function()
		vim.keymap.set("n", "<leader>yy", require("osc52").copy_operator, { expr = true, desc = "Copy to clipboard" })
		vim.keymap.set("v", "<leader>y", require("osc52").copy_visual, { desc = "Copy to clipboard" })
		vim.keymap.set("n", "<leader>yf", function()
          vim.fn.setreg("+", vim.fn.expand("%:p:."))
        end, { desc = "Yank buffer relative path" })
		vim.keymap.set("n", "<leader>yt", function()
          vim.fn.setreg("+", vim.fn.expand("%:t"))
        end, { desc = "Yank buffer filename" })
		vim.keymap.set("n", "<leader>yp", function()
          vim.fn.setreg("+", vim.fn.expand("%:p"))
        end, { desc = "Yank buffer filename" })
	end,
}
