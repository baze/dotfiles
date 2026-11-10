-- Rex config migrated from tmux, zellij, Ghostty and iTerm2.

---------------------------------------------------------------------------
-- tmux (~/.config/tmux/tmux.conf), prefix ctrl+a
---------------------------------------------------------------------------
rex.bind("ctrl+a>ctrl+a", "pane.send_key", { key = "ctrl+a" })
rex.bind("ctrl+a>shift+\\", "pane.split", { direction = "right" })
rex.bind("ctrl+a>-", "pane.split", { direction = "down" })
rex.bind("ctrl+a>r", "client.config.reload")
rex.bind("alt+shift+h", "client.tab.previous")
rex.bind("alt+shift+l", "client.tab.next")

-- bind -r: plain sequence, plus a repeat mode (ctrl+a ctrl+r; enter/escape leaves)
rex.mode("repeat", { exclusive = true })
rex.bind("ctrl+a>ctrl+r", "client.mode.enter", { name = "repeat" })
rex.bind("repeat/enter", "client.mode.exit")
rex.bind("repeat/escape", "client.mode.exit")
rex.bind("ctrl+a>j", "pane.resize", { amount = 5, direction = "down" })
rex.bind("repeat/j", "pane.resize", { amount = 5, direction = "down" })
rex.bind("ctrl+a>k", "pane.resize", { amount = 5, direction = "up" })
rex.bind("repeat/k", "pane.resize", { amount = 5, direction = "up" })
rex.bind("ctrl+a>l", "pane.resize", { amount = 5, direction = "right" })
rex.bind("repeat/l", "pane.resize", { amount = 5, direction = "right" })
rex.bind("ctrl+a>h", "pane.resize", { amount = 5, direction = "left" })
rex.bind("repeat/h", "pane.resize", { amount = 5, direction = "left" })
rex.bind("ctrl+a>m", "pane.zoom")
rex.bind("repeat/m", "pane.zoom")

---------------------------------------------------------------------------
-- zellij (~/.config/zellij/config.kdl)
---------------------------------------------------------------------------
rex.action{
  name  = "then_normal",
  title = "Run an action and return to normal mode",
  args  = { action = "string", args = "object?" },
  run   = function(ctx, args)
    rex.client.queue(args.action, args.args or {})
    rex.client.queue("client.mode.exit_all")
  end,
}

local modes = { "resize", "pane", "move", "tab", "tmux" }
for _, m in ipairs(modes) do
  rex.mode(m, { exclusive = true })
end

-- Keys that enter each mode (shared_except "<mode>" "locked")
local mode_keys = {
  { "ctrl+p", "pane" },
  { "ctrl+n", "resize" },
  { "ctrl+t", "tab" },
  { "ctrl+h", "move" },
  { "ctrl+b", "tmux" },
}
for _, k in ipairs(mode_keys) do
  rex.bind(k[1], "client.mode.enter", { name = k[2] })
  for _, m in ipairs(modes) do
    if m == k[2] then
      rex.bind(m .. "/" .. k[1], "client.mode.exit_all")
    else
      rex.bind(m .. "/" .. k[1], "client.mode.enter", { name = k[2] })
    end
  end
end

-- shared_except "normal" "locked": Enter and Esc return to normal
for _, m in ipairs(modes) do
  rex.bind(m .. "/enter", "client.mode.exit_all")
  rex.bind(m .. "/escape", "client.mode.exit_all")
end

-- shared_except "locked": bound with no mode and in every mode but locked
local shared = {
  { "alt+n", "pane.split", { direction = "auto" } },
  { "alt+i", "client.tab.move", { direction = "backward" } },
  { "alt+o", "client.tab.move", { direction = "forward" } },
  { "alt+h", "pane.focus", { direction = "left" } },
  { "alt+left", "pane.focus", { direction = "left" } },
  { "alt+l", "pane.focus", { direction = "right" } },
  { "alt+right", "pane.focus", { direction = "right" } },
  { "alt+j", "pane.focus", { direction = "down" } },
  { "alt+down", "pane.focus", { direction = "down" } },
  { "alt+k", "pane.focus", { direction = "up" } },
  { "alt+up", "pane.focus", { direction = "up" } },
}
for _, b in ipairs(shared) do
  rex.bind(b[1], b[2], b[3])
  for _, m in ipairs(modes) do
    rex.bind(m .. "/" .. b[1], b[2], b[3])
  end
end

-- locked: ctrl+g enters and leaves; zellij's own keys pass through to the program
rex.bind("ctrl+g", "client.mode.enter", { name = "locked" })
rex.bind("locked/ctrl+g", "client.mode.exit_all")
for _, m in ipairs(modes) do
  rex.bind(m .. "/ctrl+g", "client.mode.enter", { name = "locked" })
end
for _, k in ipairs(mode_keys) do
  rex.bind("locked/" .. k[1], "pane.send_key", { key = k[1] })
end
for _, b in ipairs(shared) do
  rex.bind("locked/" .. b[1], "pane.send_key", { key = b[1] })
end

-- resize
for _, d in ipairs({ { "h", "left" }, { "j", "down" }, { "k", "up" }, { "l", "right" } }) do
  rex.bind("resize/" .. d[1], "pane.resize", { direction = d[2] })
  rex.bind("resize/" .. d[2], "pane.resize", { direction = d[2] })
end

-- pane
for _, d in ipairs({ { "h", "left" }, { "l", "right" }, { "j", "down" }, { "k", "up" } }) do
  rex.bind("pane/" .. d[1], "pane.focus", { direction = d[2] })
  rex.bind("pane/" .. d[2], "pane.focus", { direction = d[2] })
end
rex.bind("pane/p", "pane.focus_next")
rex.bind("pane/n", "then_normal", { action = "pane.split", args = { direction = "auto" } })
rex.bind("pane/d", "then_normal", { action = "pane.split", args = { direction = "down" } })
rex.bind("pane/r", "then_normal", { action = "pane.split", args = { direction = "right" } })
rex.bind("pane/x", "then_normal", { action = "pane.close" })
rex.bind("pane/f", "then_normal", { action = "pane.zoom" })
rex.bind("pane/c", "then_normal", { action = "pane.rename" })

-- move
for _, d in ipairs({ { "h", "left" }, { "j", "down" }, { "k", "up" }, { "l", "right" } }) do
  rex.bind("move/" .. d[1], "pane.move", { direction = d[2] })
  rex.bind("move/" .. d[2], "pane.move", { direction = d[2] })
end

-- tab
rex.bind("tab/r", "then_normal", { action = "client.tab.rename" })
for _, key in ipairs({ "h", "left", "up", "k" }) do
  rex.bind("tab/" .. key, "client.tab.previous")
end
for _, key in ipairs({ "l", "right", "down", "j" }) do
  rex.bind("tab/" .. key, "client.tab.next")
end
rex.bind("tab/n", "then_normal", { action = "client.tab.new" })
rex.bind("tab/x", "then_normal", { action = "client.tab.close" })
rex.bind("tab/b", "then_normal", { action = "pane.move_to_new_tab" })
for i = 1, 9 do
  rex.bind("tab/" .. i, "then_normal", { action = "client.tab.goto", args = { index = i } })
end

-- tmux
rex.bind("tmux/ctrl+b", "then_normal", { action = "pane.send_key", args = { key = "ctrl+b" } })
rex.bind("tmux/shift+'", "then_normal", { action = "pane.split", args = { direction = "down" } })
rex.bind("tmux/shift+5", "then_normal", { action = "pane.split", args = { direction = "right" } })
rex.bind("tmux/z", "then_normal", { action = "pane.zoom" })
rex.bind("tmux/c", "then_normal", { action = "client.tab.new" })
rex.bind("tmux/,", "then_normal", { action = "client.tab.rename" })
rex.bind("tmux/p", "then_normal", { action = "client.tab.previous" })
rex.bind("tmux/n", "then_normal", { action = "client.tab.next" })
for _, d in ipairs({ { "h", "left" }, { "l", "right" }, { "j", "down" }, { "k", "up" } }) do
  rex.bind("tmux/" .. d[1], "then_normal", { action = "pane.focus", args = { direction = d[2] } })
  rex.bind("tmux/" .. d[2], "then_normal", { action = "pane.focus", args = { direction = d[2] } })
end
rex.bind("tmux/o", "pane.focus_next")
rex.bind("tmux/x", "then_normal", { action = "pane.close" })

---------------------------------------------------------------------------
-- iTerm2 (Default profile Keyboard Map): single-byte hex codes
---------------------------------------------------------------------------
rex.bind("ctrl+2", "pane.send_key", { key = "ctrl+space" })     -- 0x00
rex.bind("ctrl+3", "pane.send_key", { key = "esc" })            -- 0x1b
rex.bind("ctrl+4", "pane.send_key", { key = "ctrl+\\" })        -- 0x1c
rex.bind("ctrl+5", "pane.send_key", { key = "ctrl+]" })         -- 0x1d
rex.bind("ctrl+6", "pane.send_key", { key = "ctrl+shift+6" })   -- 0x1e
rex.bind("ctrl+7", "pane.send_key", { key = "ctrl+shift+-" })   -- 0x1f
rex.bind("ctrl+-", "pane.send_key", { key = "ctrl+shift+-" })   -- 0x1f
rex.bind("ctrl+8", "pane.send_key", { key = "backspace" })      -- 0x7f
