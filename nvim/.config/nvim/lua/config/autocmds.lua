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

vim.api.nvim_create_autocmd("ModeChanged", {
	group = vim.api.nvim_create_augroup("diagnostic_redraw", {}),
	callback = function()
		pcall(vim.diagnostic.show)
	end,
})

local group = vim.api.nvim_create_augroup("OoO", {})

local function au(typ, pattern, cmdOrFn)
	if type(cmdOrFn) == "function" then
		vim.api.nvim_create_autocmd(typ, { pattern = pattern, callback = cmdOrFn, group = group })
	else
		vim.api.nvim_create_autocmd(typ, { pattern = pattern, command = cmdOrFn, group = group })
	end
end

au({ "CursorHold", "InsertLeave" }, nil, function()
	local opts = {
		focusable = false,
		scope = "cursor",
		close_events = { "BufLeave", "CursorMoved", "InsertEnter" },
	}
	vim.diagnostic.open_float(nil, opts)
end)

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local bufnr = args.buf
		vim.keymap.set("n", "K", function()
			vim.lsp.buf.hover({ border = "rounded" })
		end, { buffer = bufnr })
	end,
})
