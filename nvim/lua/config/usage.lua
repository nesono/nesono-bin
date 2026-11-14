local M = {}

-- Store only stable action labels, never buffer names or command arguments.
function M.record(feature)
	if vim.env.NESONO_USAGE == "0" then
		return
	end
	pcall(function()
		local state = vim.env.XDG_STATE_HOME
		if not state or state == "" then
			state = vim.env.HOME .. "/.local/state"
		end
		local dir = state .. "/nesono-bin"
		vim.fn.mkdir(dir, "p", 448)
		local uv = vim.uv or vim.loop
		local fd = uv.fs_open(dir .. "/usage.tsv", "a", 384)
		if fd then
			uv.fs_write(fd, os.time() .. "\tnvim\t" .. feature:gsub("[\t\r\n]", " ") .. "\n", -1)
			uv.fs_close(fd)
		end
	end)
end

-- Expression wrappers preserve string RHS command-line prompts and remapping
-- behavior; callbacks keep their original options and return values.
local function wrap(lhs, rhs, opts)
	opts = vim.tbl_extend("force", {}, opts or {})
	local feature = opts.desc or lhs
	if type(rhs) == "function" then
		return function(...)
			M.record(feature)
			return rhs(...)
		end, opts
	else
		local expr = opts.expr
		opts.expr = true
		return function()
			M.record(feature)
			if expr then
				return vim.api.nvim_eval(rhs)
			end
			return rhs
		end,
			opts
	end
end

function M.map(mode, lhs, rhs, opts)
	local callback, options = wrap(lhs, rhs, opts)
	vim.keymap.set(mode, lhs, callback, options)
end

-- Instrument lazy.nvim key specs without changing when the plugin loads.
function M.plugin(spec)
	for _, key in ipairs(spec.keys or {}) do
		if type(key) == "table" and key[2] then
			local callback, options = wrap(key[1], key[2], { desc = key.desc, expr = key.expr })
			key[2] = callback
			key.expr = options.expr
		end
	end
	return spec
end

return M
