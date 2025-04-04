-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

--vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

-- vim.opt.colorcolumn = "80"
vim.opt.cursorcolumn = false
vim.opt.cursorline = true

-- LSP Server to use for PHP.
-- Set to "intelephense" to use intelephense instead of phpactor.
vim.g.lazyvim_php_lsp = "intelephense"

-- Set EOL to \n (Unix-style)
vim.opt.fileformat = "unix"

-- Show hidden whitespace characters
vim.opt.list = true
vim.opt.listchars = {
	-- space = "·", -- Show spaces as a middle dot
	tab = "→ ", -- Show tabs as an arrow followed by a space
	trail = "•", -- Show trailing spaces as a bullet
	extends = "❯", -- Show character when the line extends beyond the window
	precedes = "❮", -- Show character when there is text before the start of the window
	nbsp = "␣", -- Show non-breaking spaces as a symbol
	-- eol = "↵", -- Show EOL as a symbol
}

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.clipboard = "unnamedplus"

vim.opt.virtualedit = "block"
vim.g.lazyvim_picker = "snacks"

vim.diagnostic.config({
  -- Use the default configuration
  virtual_lines = true

  -- Alternatively, customize specific options
  -- virtual_lines = {
  --  -- Only show virtual line diagnostics for the current cursor line
  --  current_line = true,
  -- },
})
