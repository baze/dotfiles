return {
	"barrett-ruth/import-cost.nvim",
	build = function()
		vim.fn.system({ "sh", "install.sh", "npm" })
	end,
	-- config = true,
}
