local util = require("conform.util")
return {
	"stevearc/conform.nvim",
	opts = function()
		---@type conform.setupOpts
		local opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				fish = { "fish_indent" },
				sh = { "shfmt" },
				php = { "pint" },
				blade = { "blade-formatter", "rustywind" },
				python = { "isort", "black" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				svelte = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				graphql = { "prettier" },
			},
			format_on_save = {
				lsp_fallback = true,
				async = true,
				timeout_ms = 1000,
			},
			-- LazyVim will merge the options you set here with builtin formatters.
			-- You can also define any custom formatters here.
			---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
			formatters = {
				injected = { options = { ignore_errors = true } },
				-- # Example of using dprint only when a dprint.json file is present
				-- dprint = {
				--   condition = function(ctx)
				--     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
				--   end,
				-- },
				--
				-- # Example of using shfmt with extra args
				-- shfmt = {
				--   extra_args = { "-i", "2", "-ci" },
				-- },
				pint = {
					meta = {
						url = "https://github.com/laravel/pint",
						description = "Laravel Pint is an opinionated PHP code style fixer for minimalists. Pint is built on top of PHP-CS-Fixer and makes it simple to ensure that your code style stays clean and consistent.",
					},
					command = util.find_executable({
						vim.fn.stdpath("data") .. "/mason/bin/pint",
						"vendor/bin/pint",
					}, "pint"),
					args = { "$FILENAME" },
					stdin = false,
				},
			},
		}
		return opts
	end,
}
