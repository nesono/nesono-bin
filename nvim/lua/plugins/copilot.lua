return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
	config = function()
		require("copilot").setup({
            suggestion = {
				enabled = true,
			    auto_trigger = true,
				keymap = {
					accept = "<Tab>",
					next = "<C-l>",
					prev = "<C-h>",
				},
			},
            panel = { enabled = true },
        })
	end,
}
