return {
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				svelte = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				vue = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				graphql = { "prettier" },
				liquid = { "prettier" },
				lua = { "stylua" },
				python = { "isort", "black" },
				php = { "pint" },
				blade = { "blade-formatter" },
			},
		},
	},
	{
		-- Remove phpcs linter.
		"mfussenegger/nvim-lint",
		optional = true,
		opts = {
			linters_by_ft = {
				php = {},
			},
		},
	},
}
