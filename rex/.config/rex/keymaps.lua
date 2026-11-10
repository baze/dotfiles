local actions = require("actions")

rex.bind("cmd+s", "scratch_float")
rex.bind("cmd+g", "lazygit_float")

-- vim-tmux-navigator: ctrl+h/j/k/l move between panes. When (n)vim or fzf runs
-- in the focused pane the key goes to it instead, so vim can move between its
-- own splits first and hand off to Rex at the edge (`rex focus <dir>`).
local passthrough = {
  vi = true, vim = true, nvim = true, view = true, vimdiff = true, nvimdiff = true, fzf = true,
}

for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind("ctrl+" .. key, function(ctx)
    local fg = actions.foreground(ctx)
    if fg and passthrough[fg.name] then
      return false
    end
    rex.session.focus_direction({ session_id = ctx.session_id, direction = direction })
    return true
  end)
end
