return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			-- @type lspconfig.options
			servers = {
				emmet_language_server = {
					filetypes = {
						"css",
						"eruby",
						"html",
						"javascript",
						"javascriptreact",
						"less",
						"sass",
						"scss",
						"pug",
						"typescriptreact",
						"blade",
						"php",
						"vue",
					},
				},
			},
		},
	},
}
