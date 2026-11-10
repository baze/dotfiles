-- Inside tmux, use the plugin. Inside Rex (REX_BLOCK set), move between vim
-- splits and hand off to Rex with `rex focus` at the edge.
local function navigate(wincmd, tmux_cmd, rex_dir)
	return function()
		if vim.env.TMUX or not vim.env.REX_BLOCK then
			vim.cmd(tmux_cmd)
			return
		end
		local win = vim.api.nvim_get_current_win()
		vim.cmd("wincmd " .. wincmd)
		if vim.api.nvim_get_current_win() == win then
			vim.system({ "rex", "focus", rex_dir })
		end
	end
end

return {
	"christoomey/vim-tmux-navigator",
	init = function()
		-- the plugin's own <C-h/j/k/l> maps would replace the ones below
		vim.g.tmux_navigator_no_mappings = 1
	end,
	cmd = {
		"TmuxNavigateLeft",
		"TmuxNavigateDown",
		"TmuxNavigateUp",
		"TmuxNavigateRight",
		"TmuxNavigatePrevious",
	},
	keys = {
		{ "<c-h>", navigate("h", "TmuxNavigateLeft", "left") },
		{ "<c-j>", navigate("j", "TmuxNavigateDown", "down") },
		{ "<c-k>", navigate("k", "TmuxNavigateUp", "up") },
		{ "<c-l>", navigate("l", "TmuxNavigateRight", "right") },
		{ "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
	},
}
