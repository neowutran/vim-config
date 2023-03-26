-- Plugin: Lualine
-- https://github.com/rafi/vim-config

return {

	-----------------------------------------------------------------------------
	{
		'nvim-lualine/lualine.nvim',
		dependencies = {
			'nvim-lua/plenary.nvim',
			'nvim-tree/nvim-web-devicons',
		},
		event = 'VeryLazy',
		init = function()
			vim.g.qf_disable_statusline = true
		end,
		opts = function()
			local icons = require('rafi.config').icons
			local extract = require('lualine.utils.utils').extract_color_from_hllist

			local function fg(name)
				return function()
					---@type {foreground?:number}?
					local hl = vim.api.nvim_get_hl_by_name(name, true)
					return hl and hl.foreground and {
						fg = string.format('#%06x', hl.foreground)
					}
				end
			end

			local function filepath()
				local fpath = require('rafi.lib.badge').filepath(0, 3, 5)
				return fpath:gsub('%%', '%%%%')
			end

			local function is_min_width(min)
				if vim.o.laststatus > 2 then
					return vim.o.columns > min
				end
				return vim.fn.winwidth(0) > min
			end

			local active = {
				fg = extract('fg', { 'StatusLine' }, '#000000'),
				bg = extract('bg', { 'StatusLine' }, '#000000'),
			}
			local inactive = {
				fg = extract('fg', { 'StatusLineNC' }, '#666656'),
				bg = extract('bg', { 'StatusLineNC' }, '#000000'),
			}
			local theme = {
				normal = {
					a = active, b = active, c = active,
					x = active, y = active,
					z = {
						fg = active.fg,
						bg = require('rafi.lib.color').brightness_modifier(active.bg, 63),
					},
				},
				inactive = {
					a = inactive, b = inactive, c = inactive,
					x = inactive, y = inactive, z = inactive,
				},
			}

			return {
				options = {
					theme = theme,
					globalstatus = true,
					always_divide_middle = false,
					disabled_filetypes = {
						statusline = { 'dashboard', 'lazy', 'alpha' }
					},
					component_separators = '',
					section_separators   = '',
				},
				sections = {
					lualine_a = {
						-- Left edge block.
						{
							function() return '▊' end,
							color = { fg = extract('fg', {'Directory'}, '#51afef') },
							padding = 0,
						},

						-- Readonly/zoomed/hash symbol.
						{
							padding = { left = 1, right = 0 },
							function()
								if vim.bo.buftype == '' and vim.bo.readonly then
									return icons.status.filename.readonly
								elseif vim.t['zoomed'] then
									return icons.status.filename.zoomed
								end
								return '%*#'
							end,
						},

						-- Buffer number.
						{ function() return '%n' end, padding = 0 },

						-- Modified symbol.
						{
							function()
								return vim.bo.modified and icons.status.filename.modified or ''
							end,
							padding = 0,
							color = { fg = extract('bg', {'DiffDelete'}, '#ec5f67') },
						},
					},

					lualine_b = {
						{ 'filetype', icon_only = true, padding = { left = 1, right = 0 }},
						{
							filepath,
							padding = { left = 1, right = 0 },
							color = { fg = '#D7D7BC' }
						},
					},

					lualine_c = {
						{
							'diagnostics',
							padding = { left = 1, right = 0 },
							symbols = {
								error = icons.status.diagnostics.error,
								warn = icons.status.diagnostics.warn,
								info = icons.status.diagnostics.info,
								hint = icons.status.diagnostics.hint,
							},
						},

						-- Whitespace trails
						{
							function() return require('rafi.lib.badge').trails('␣') end,
							padding = { left = 1, right = 0 },
							color = { fg = extract('bg', {'Identifier'}, '#b294bb') },
						},

						-- Start truncating here
						{ function() return '%<' end, padding = 0 },

						{ 'branch', icon = '', padding = 1 },

						{
							'diff',
							symbols = {
								added = icons.status.git.added,
								modified = icons.status.git.modified,
								removed = icons.status.git.removed,
							},
							padding = 0,
							cond = function() return is_min_width(70) end,
						},
						-- {
						-- 	function() return require('nvim-navic').get_location() end,
						-- 	cond = function()
						-- 		return is_min_width(100)
						-- 			and package.loaded['nvim-navic']
						-- 			and require('nvim-navic').is_available()
						-- 	end,
						-- },
					},
					lualine_x = {
						{
							function() return require('noice').api.status.command.get() end,
							cond = function()
								return package.loaded['noice']
									and require('noice').api.status.command.has()
							end,
							color = fg('Statement'),
						},
						{
							function() return require('noice').api.status.mode.get() end,
							cond = function()
								return package.loaded['noice']
									and require('noice').api.status.mode.has()
							end,
							color = fg('Constant'),
						},
						{
							function() require("noice").api.status.search.get() end,
							cond = function() require("noice").api.status.search.has() end,
							color = { fg = "ff9e64" },
						},
						{
							require('lazy.status').updates,
							cond = require('lazy.status').has_updates,
							color = fg('Special'),
						},
					},
					lualine_y = {
						-- File format, encoding and type.
						{
							function() return require('rafi.lib.badge').filemedia('  ') end,
							cond = function() return is_min_width(60) end,
							separator = { left = '' },
							padding = { left = 0, right = 1 },
						},
					},
					lualine_z = {
						{
							function() return '%l/%2c%4p%%' end,
							separator = { left = '' },
							padding = 1,
						},
					},
				},
				inactive_sections = {
					lualine_a = {
						-- File icon.
						{
							'filetype',
							icon_only = true,
							colored = false,
							padding = { left = 1, right = 0 },
						},
						{ filepath, padding = { left = 1, right = 0 } },
						{
							function()
								return vim.bo.modified
									and vim.bo.buftype == ''
									and icons.status.filename.modified
									or ''
							end,
							padding = 1,
							color = { fg = extract('bg', {'DiffDelete'}, '#ec5f67') },
						},
					},
					lualine_b = {},
					lualine_c = {},
					lualine_x = {},
					lualine_y = {},
					lualine_z = { { function() return vim.bo.filetype end } }
				},
				extensions = {
					'man',
					'fugitive',
					{
						filetypes = {'TelescopePrompt'},
						sections = {
							lualine_a = {
								{ function() return require('rafi.lib.badge').icon() end },
								{ filepath, padding = 0 },
							},
						},
					},
					{
						filetypes = {'Trouble', 'DiffviewFiles', 'NeogitStatus', 'Outline'},
						sections = {
							lualine_a = {
								{
									function() return require('rafi.lib.badge').icon() end,
									padding = 1
								},
								{ filepath },
							},
							lualine_z = { function() return '%l/%L' end },
						},
						inactive_sections = {
							lualine_a = { function() return require('rafi.lib.badge').icon() end },
							lualine_z = { function() return '%l/%L' end },
						},
					},
					-- Extension: File-explorer
					{
						filetypes = {'neo-tree'},
						sections = {
							lualine_a = {
								{
									function() return '▊' end,
									-- color = { fg = colors.active.boundary },
									color = { fg = extract('fg', {'Directory'}, '#51afef') },
									padding = 0,
								},
								{ function() return '' end, padding = 1 },
								{ function() return '%<' end, padding = 0 },
								{
									function()
										return vim.fn.fnamemodify(vim.loop.cwd(), ':~')
									end,
									padding = { left = 0, right = 1 },
								}
							},
							lualine_z = { function() return '%l/%L' end },
						},
						inactive_sections = {
							lualine_a = {
								{ function() return '' end, padding = 1 },
								{ function() return '%<' end, padding = { left = 1, right = 0 }},
								{
									function() return vim.fn.fnamemodify(vim.fn.getcwd(), ':~') end,
									padding = { left = 0, right = 1 },
								}
							},
							lualine_z = { function() return '%l/%L' end },
						},
					},
					-- Extension: Quickfix or location list.
					{
						filetypes = {'qf'},
						sections = {
							lualine_a = {
								{
									function()
										if vim.fn.win_gettype() == 'loclist' then
											return ' ' .. 'Location List'
										end
										return ' ' .. 'Quickfix List'
									end,
									padding = { left = 1, right = 0 },
								},
								{
									function()
										if vim.fn.win_gettype() == 'loclist' then
											return vim.fn.getloclist(0, { title = 0 }).title
										end
										return vim.fn.getqflist({ title = 0 }).title
									end
								},
							},
							lualine_z = { function() return '%l/%L' end },
						},
					},
				},
			}
		end,
	},

}