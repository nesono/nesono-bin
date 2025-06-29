return {
	'nvim-lualine/lualine.nvim',
	dependencies = { 'nvim-tree/nvim-web-devicons' },
	config = function()
		require('lualine').setup {
			options = {
				theme = 'iceberg',         -- or 'gruvbox', 'onedark', etc.
				icons_enabled = true,   -- needs nvim-web-devicons for full effect
				section_separators = { left = '', right = '' },
				component_separators = { left = '', right = '' },
			},
			sections = {
				lualine_a = { 'mode' },
				lualine_b = { 'branch', 'diff', 'diagnostics' },
				lualine_c = { { 'filename', path = 1 } }, -- 0=just name, 1=relative, 2=absolute
				lualine_x = { 'encoding', 'fileformat', 'filetype' },
				lualine_y = { 'progress' },
				lualine_z = { 'location' }
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { { 'filename', path = 1 } },
				lualine_x = { 'location' },
				lualine_y = {},
				lualine_z = {}
			},
			extensions = { 'nvim-tree', 'fugitive', 'quickfix' }
		}
	end
}
