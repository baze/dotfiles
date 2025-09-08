return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = function(_, opts)
			-- merge your own settings into opts
			opts.flavour = "macchiato" -- latte, frappe, macchiato, mocha
			opts.transparent_background = false

			-- bufferline integration fix
			local ok, bufferline = pcall(require, "catppuccin.groups.integrations.bufferline")
			if ok and bufferline then
				bufferline.get = bufferline.get_theme
			end

			return opts
		end,
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
	-- {
	-- 	"shaunsingh/nord.nvim",
	-- },
	-- {
	-- 	"loctvl842/monokai-pro.nvim",
	-- },
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "catppuccin",
			-- colorscheme = "kanagawa",
			-- colorscheme = "tokyonight",
			-- colorscheme = "sonokai",
			-- colorscheme = "monokai-pro",
		},
	},
}
