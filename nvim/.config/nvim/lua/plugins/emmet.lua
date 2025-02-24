return {
	-- Mason-LSPConfig to bridge Mason and LSPConfig
	{
		"williamboman/mason-lspconfig.nvim",
		opts = {
			ensure_installed = { "emmet_language_server" },
			automatic_installation = true,
		},
		config = function()
			require("mason-lspconfig").setup_handlers({
				-- Default handler for all servers
				function(server_name)
					require("lspconfig")[server_name].setup({})
				end,

				-- Custom handler for emmet_language_server
				["emmet_language_server"] = function()
					require("lspconfig").emmet_language_server.setup({
						filetypes = {
							"html",
							"css",
							"scss",
							"javascript",
							"javascriptreact",
							"typescriptreact",
							"vue",
							"blade",
							"pug",
							"less",
						},
						init_options = {
							html = { options = { ["bem.enabled"] = true } },
						},
					})
				end,
			})
		end,
	},
	{
		"olrtg/nvim-emmet",
		config = function()
			vim.keymap.set({ "n", "v" }, "<leader>xe", require("nvim-emmet").wrap_with_abbreviation)
		end,
	},
}
