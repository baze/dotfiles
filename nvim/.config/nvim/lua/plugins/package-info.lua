return {
	"vuki656/package-info.nvim",
	ft = "json",
	dependencies = { "MunifTanjim/nui.nvim" },
	config = function()
		require("package-info").setup({
			autostart = true,
			package_manager = "npm",
			colors = { outdated = "#db4b4b" },
			hide_up_to_date = true,
		})

		local keymap = vim.keymap.set
		local package_info = require("package-info")

		-- Key mappings for package-info functions with descriptions
		keymap(
			"n",
			"<leader>ns",
			package_info.show,
			{ silent = true, noremap = true, desc = "Show dependency versions" }
		)
		keymap(
			"n",
			"<leader>nc",
			package_info.hide,
			{ silent = true, noremap = true, desc = "Hide dependency versions" }
		)
		keymap(
			"n",
			"<leader>nt",
			package_info.toggle,
			{ silent = true, noremap = true, desc = "Toggle dependency versions" }
		)
		keymap(
			"n",
			"<leader>nu",
			package_info.update,
			{ silent = true, noremap = true, desc = "Update dependency on the line" }
		)
		keymap(
			"n",
			"<leader>nd",
			package_info.delete,
			{ silent = true, noremap = true, desc = "Delete dependency on the line" }
		)
		keymap(
			"n",
			"<leader>ni",
			package_info.install,
			{ silent = true, noremap = true, desc = "Install a new dependency" }
		)
		keymap(
			"n",
			"<leader>np",
			package_info.change_version,
			{ silent = true, noremap = true, desc = "Install a different dependency version" }
		)
	end,
}
