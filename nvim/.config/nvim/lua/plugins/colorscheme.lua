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
		"sainnhe/sonokai",
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "catppuccin",
			-- colorscheme = "kanagawa",
			-- colorscheme = "sonokai",
		},
	},
}
