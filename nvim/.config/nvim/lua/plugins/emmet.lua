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
						"vue",
					},
				},
			},
		},
	},
	{
		"olrtg/nvim-emmet",
		config = function()
			vim.keymap.set(
				{ "n", "v" },
				"<leader>xe",
				require("nvim-emmet").wrap_with_abbreviation,
				{ silent = true, noremap = true, desc = "Wrap with abbreviation" }
			)
		end,
	},
}
