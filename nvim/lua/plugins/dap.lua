if vim.env.enable_dapui ~= "1" then
	return {}
end

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
		local pickers = require('telescope.pickers')
		local finders = require('telescope.finders')
		local conf = require('telescope.config').values
		local actions = require('telescope.actions')
		local action_state = require('telescope.actions.state')
		dapui.setup()
		function _dapui_toggle()
			dapui.toggle()
		end
		vim.api.nvim_set_keymap("n", "<leader>dd", "<cmd>lua _dapui_toggle()<cr>", { noremap = true, silent = true })

		local function telescope_pick_process()
		  local output = vim.fn.systemlist("ps -eo pid,comm")
		  local processes = {}
		  for _, line in ipairs(output) do
			local pid, name = line:match(" *(%d+) (.+)")
			if pid and name and pid ~= "PID" then
			  table.insert(processes, {pid = pid, name = name})
			end
		  end

		  pickers.new({}, {
			prompt_title = 'Select process to attach',
			finder = finders.new_table {
			  results = processes,
			  entry_maker = function(entry)
				return {
				  value = entry,
				  display = entry.pid .. " - " .. entry.name,
				  ordinal = entry.pid .. " " .. entry.name,
				}
			  end
			},
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
			  actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				dap.run({
				  type = 'pwa-node', -- or your debugger type
				  request = 'attach',
				  processId = tonumber(selection.value.pid),
				  name = 'Attach with Telescope',
				})
			  end)
			  return true
			end
		  }):find()
		end

		dapui.setup()

		dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
		dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
		dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
		-- If this fails, run `python -m venv ~/.venv && source ~/.venv/bin/activate && pip install debugpy`
		require("dap-python").setup(vim.fn.expand("~/.venv/bin/debugpy-adapter"))

		-- Key mappings for DAP
		vim.keymap.set('n', '<Leader>dc', function() require('dap').continue() end, { desc = "DAP Continue/Start" })
		vim.keymap.set('n', '<Leader>dn', function() require('dap').step_over() end, { desc = "DAP Step Over" })
		vim.keymap.set('n', '<Leader>ds', function() require('dap').step_into() end, { desc = "DAP Step Into" })
		vim.keymap.set('n', '<Leader>du', function() require('dap').step_out() end, { desc = "DAP Step Out" })
		vim.keymap.set('n', '<Leader>db', function() require('dap').toggle_breakpoint() end, { desc = "DAP Toggle Breakpoint" })
		vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end, { desc = "DAP Run Last" })
		vim.keymap.set('n', '<Leader>de', function() require('dapui').eval() end, { desc = "Eval expression under cursor" })


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
					processId = function()
						telescope_pick_process()
						return nil
					end,
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
