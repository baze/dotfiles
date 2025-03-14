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
	-- {
	-- 	"rebelot/kanagawa.nvim",
	-- 	opts = {
	-- 		theme = "wave",
	-- 	},
	-- },
	-- {
	-- 	"sainnhe/sonokai",
	-- },
	-- {
	-- 	"folke/tokyonight.nvim",
	-- },
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "catppuccin",
			-- colorscheme = "kanagawa",
			-- colorscheme = "tokyonight",
			-- colorscheme = "sonokai",
		},
	},
}
