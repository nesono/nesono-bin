return {
	"rcarriga/nvim-dap-ui",
	dependencies = {
		"mfussenegger/nvim-dap",
		"nvim-neotest/nvim-nio",
		"mfussenegger/nvim-dap-python",
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		dapui.setup()

		dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
		dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
		dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
		require("dap-python").setup("uv")

		-- Key mappings for DAP
		vim.keymap.set('n', '<Leader>dc', function() require('dap').continue() end, { desc = "DAP Continue/Start" })
		vim.keymap.set('n', '<Leader>dn', function() require('dap').step_over() end, { desc = "DAP Step Over" })
		vim.keymap.set('n', '<Leader>ds', function() require('dap').step_into() end, { desc = "DAP Step Into" })
		vim.keymap.set('n', '<Leader>du', function() require('dap').step_out() end, { desc = "DAP Step Out" })
		vim.keymap.set('n', '<Leader>db', function() require('dap').toggle_breakpoint() end, { desc = "DAP Toggle Breakpoint" })
		vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end, { desc = "DAP Run Last" })
	end,
}
