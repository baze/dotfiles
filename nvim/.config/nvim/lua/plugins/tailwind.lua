return {
	-- {
	-- 	"neovim/nvim-lspconfig",
	-- 	opts = {
	-- 		-- @type lspconfig.options
	-- 		servers = {
	-- 			tailwindcss = {
	-- 				settings = {
	-- 					tailwindCSS = {
	-- 						experimental = {
	-- 							classRegex = {
	-- 								"@?class\\(([^]*)\\)",
	-- 								"'([^']*)'",
	-- 							},
	-- 						},
	-- 					},
	-- 				},
	-- 			},
	-- 		},
	-- 	},
	-- },
	{
		"NvChad/nvim-colorizer.lua",
		opts = {
			user_default_options = {
				tailwind = true,
			},
		},
	},
}
