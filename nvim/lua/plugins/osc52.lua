return {
	"ojroques/nvim-osc52",
	config = function()
		require("config.usage").map("n", "<leader>yy", require("osc52").copy_operator, { expr = true, desc = "Copy to clipboard" })
		require("config.usage").map("v", "<leader>y", require("osc52").copy_visual, { desc = "Copy to clipboard" })
		require("config.usage").map("n", "<leader>yf", function()
          vim.fn.setreg("+", vim.fn.expand("%:p:."))
        end, { desc = "Yank buffer relative path" })
		require("config.usage").map("n", "<leader>yt", function()
          vim.fn.setreg("+", vim.fn.expand("%:t"))
        end, { desc = "Yank buffer filename" })
		require("config.usage").map("n", "<leader>yp", function()
          vim.fn.setreg("+", vim.fn.expand("%:p"))
        end, { desc = "Yank buffer filename" })
	end,
}
