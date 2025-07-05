if vim.env.DISABLE_COPILOT == "1" then
  return {}
end

return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
	config = function()
		require("copilot").setup({
			filetypes = {
				netrc = false,
				sshconfig = false,
			},
            suggestion = {
				enabled = true,
			    auto_trigger = true,
				keymap = {
					accept = "<Tab>",
					next = "<C-l>",
					prev = "<C-h>",
					accept_word = "<C-y>",
					accept_line = "<C-e>",
				},
			},
            panel = { enabled = true },
        })
	end,
}
