-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Trim trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	command = [[%s/\s\+$//e]],
})

-- vim.api.nvim_create_autocmd("CursorHold", {
-- 	buffer = bufnr,
-- 	callback = function()
-- 		local opts = {
-- 			focusable = false,
-- 			close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
-- 			-- border = "rounded",
-- 			source = "always",
-- 			prefix = " ",
-- 			scope = "cursor",
-- 		}
-- 		vim.diagnostic.open_float(nil, opts)
-- 	end,
-- })

vim.api.nvim_create_autocmd("VimEnter", {
	group = vim.api.nvim_create_augroup("restore_session", { clear = true }),
	callback = function()
		if vim.fn.getcwd() ~= vim.env.HOME then
			require("persistence").load()
		end
	end,
	nested = true,
})
