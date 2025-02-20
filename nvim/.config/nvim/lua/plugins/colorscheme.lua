return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			flavour = "macchiato", -- latte, frappe, macchiato, mocha
			transparent_background = false,
		},
	},
	{
		"rebelot/kanagawa.nvim",
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "catppuccin",
			-- colorscheme = "kanagawa",
		},
	},
}
