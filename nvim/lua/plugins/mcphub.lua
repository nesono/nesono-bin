return {
    "ravitemer/mcphub.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    build = "npm install -g mcp-hub@latest",  -- Installs `mcp-hub` node binary globally
    config = function()
        require("mcphub").setup({
			global_env = {
				"GITHUB_PERSONAL_ACCESS_TOKEN",
			},
		})
		vim.keymap.set("n", "<leader>hh", ":MCPHub<cr>")
    end
}
