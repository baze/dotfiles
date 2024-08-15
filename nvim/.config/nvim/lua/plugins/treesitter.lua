-- add more treesitter parsers
return {
	"nvim-treesitter/nvim-treesitter",
	opts = {
		ensure_installed = { "php", "javascript", "html", "css", "json", "typescript", "blade", "vue" },
		auto_install = true,
		highlight = {
			enable = true,
		},
		-- Needed because treesitter highlight turns off autoindent for php files
		indent = {
			enable = true,
		},
	},
	config = function(_, opts)
		---@class ParserInfo[]
		local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
		parser_config.blade = {
			install_info = {
				url = "https://github.com/EmranMR/tree-sitter-blade",
				files = { "src/parser.c" },
				branch = "main",
			},
			filetype = "blade",
		}

		vim.filetype.add({
			pattern = {
				[".*%.blade%.php"] = "blade",
			},
		})
		require("nvim-treesitter.configs").setup(opts)
	end,
}
