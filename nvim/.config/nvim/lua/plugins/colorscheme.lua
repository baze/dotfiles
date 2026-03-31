return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			flavour = "macchiato",
			transparent_background = false,
		},
		specs = {
			{
				"akinsho/bufferline.nvim",
				optional = true,
				opts = function(_, opts)
					if (vim.g.colors_name or ""):find("catppuccin") then
						opts.highlights = require("catppuccin.special.bufferline").get_theme()
					end
				end,
			},
		},
	},

	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = function()
				vim.cmd.colorscheme("catppuccin-nvim")
			end,
		},
	},
}
