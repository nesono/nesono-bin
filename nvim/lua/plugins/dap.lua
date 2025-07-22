return {
	"rcarriga/nvim-dap-ui",
	dependencies = {
		"mfussenegger/nvim-dap",
		"nvim-neotest/nvim-nio",
		"mfussenegger/nvim-dap-python",
		"mxsdev/nvim-dap-vscode-js",
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


		require("dap-vscode-js").setup({
			-- node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
			debugger_path = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy/nvim-dap-vscode-js"), -- Path to vscode-js-debug installation.
			-- debugger_cmd = { "extension" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
			adapters = { 'chrome', 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost', 'node', 'chrome' }, -- which adapters to register in nvim-dap
			-- log_file_path = "(stdpath cache)/dap_vscode_js.log" -- Path for file logging
			-- log_file_level = false -- Logging level for output to file. Set to false to disable file logging.
			-- log_console_level = vim.log.levels.ERROR -- Logging level for output to console. Set to false to disable console output.
		})
		local js_based_languages = { "typescript", "javascript", "typescriptreact" }

		for _, language in ipairs(js_based_languages) do
			require("dap").configurations[language] = {
				{
					type = "pwa-node",
					request = "launch",
					name = "Launch file",
					program = "${file}",
					cwd = "${workspaceFolder}",
				},
				{
					type = "pwa-node",
					request = "attach",
					name = "Attach",
					processId = require 'dap.utils'.pick_process,
					cwd = "${workspaceFolder}",
				},
				{
					type = "pwa-chrome",
					request = "launch",
					name = "Start Chrome with \"localhost\"",
					url = "http://localhost:3000",
					webRoot = "${workspaceFolder}",
					userDataDir = "${workspaceFolder}/.vscode/vscode-chrome-debug-userdatadir"
				}
			}
		end
	end,
}
