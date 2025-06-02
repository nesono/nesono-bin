return {
	"nvimdev/dashboard-nvim",
	event = "VimEnter",
	config = function()
		require("dashboard").setup({
			config = {
				week_header = { enable = true },
				shortcut = {
					{ desc = "Update Plugins", group = "@property", action = "Lazy update", key = "u" },
					{ desc = "  Load Last Session", group = "@property", action = "SessionLoad", key = "l" },
					{ desc = "  New File", group = "@property", action = "enew", key = "n" },
					{ desc = "  Find Files", group = "@property", action = "Telescope find_files", key = "f" },
					{ desc = "  Recent Files", group = "@property", action = "Telescope oldfiles", key = "r" },
					{ desc = "  Grep", group = "@property", action = "Telescope live_grep", key = "w" },
				},
			},
		})
	end,
	dependencies = { { "nvim-tree/nvim-web-devicons" } },
}
