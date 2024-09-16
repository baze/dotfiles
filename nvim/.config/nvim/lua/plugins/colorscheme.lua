return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			flavour = "macchiato", -- latte, frappe, macchiato, mocha
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
