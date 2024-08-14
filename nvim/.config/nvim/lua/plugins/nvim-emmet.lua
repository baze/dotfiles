return {
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
