-- add more treesitter parsers
return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				"c",
				"lua",
				"vim",
				"vimdoc",
				"query",
				"php",
				"javascript",
				"html",
				"css",
				"json",
				"typescript",
				"blade",
				"vue",
			},
			auto_install = true,
			highlight = {
				enable = true,
			},
			-- Needed because treesitter highlight turns off autoindent for php files
			indent = {
				enable = true,
			},

			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
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
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
}
