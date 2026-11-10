local terminal = "com.superlogical.terminal"

-- the focused pane's foreground process, with its name, pid and cwd
local function foreground(ctx)
  local ok, proc = pcall(rex.block.call, terminal, "process", { block_id = ctx.block_id })
  return ok and proc and proc.foreground or nil
end

-- the focused pane's directory: the foreground process's cwd (follows nvim's :cd),
-- else what the shell last reported
local function focused_cwd(ctx)
  local fg = foreground(ctx)
  if fg and fg.cwd then
    return fg.cwd
  end
  local ok, pwd = pcall(rex.block.call, terminal, "pwd", { block_id = ctx.block_id })
  if ok and pwd and pwd.pwd then
    return (pwd.pwd:gsub("^file://[^/]*", ""))
  end
end

-- vim-tmux-navigator: ctrl+h/j/k/l move between panes. When (n)vim or fzf runs
-- in the focused pane the key goes to it instead, so vim can move between its
-- own splits first and hand off to Rex at the edge (`rex focus <dir>`).
local passthrough = {
  vi = true, vim = true, nvim = true, view = true, vimdiff = true, nvimdiff = true, fzf = true,
}

for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind("ctrl+" .. key, function(ctx)
    local fg = foreground(ctx)
    if fg and passthrough[fg.name] then
      return false
    end
    rex.session.focus_direction({ session_id = ctx.session_id, direction = direction })
    return true
  end)
end

-- cmd+g: toggle a floating lazygit in the focused pane's directory. A second
-- press closes the session's lazygit float again.
local function lazygit_layer(ctx)
  local view = rex.call("session.view", { session_id = ctx.session_id })
  for _, window in ipairs(view.windows or {}) do
    for _, layer in ipairs(window.layers or {}) do
      for _, block in ipairs(layer.kind ~= "tiled" and layer.blocks or {}) do
        if block.label == "lazygit" then
          return layer.layer_id
        end
      end
    end
  end
end

rex.action({
  name = "lazygit_float",
  title = "Toggle Lazygit",
  keywords = "git lazygit float",
  run = function(ctx)
    local layer_id = lazygit_layer(ctx)
    if layer_id then
      rex.session.close_layer({ session_id = ctx.session_id, layer_id = layer_id })
      return
    end
    local _, err = rex.session.new_layer({
      session_id = ctx.session_id,
      bounds = { 0.05, 0.05, 0.9, 0.9 },
      layout = rex.layout.block({
        flavor = terminal .. ".shell",
        label = "lazygit",
        options = { command = { "lazygit" }, cwd = focused_cwd(ctx), interactive = true },
      }),
      focus = true,
    })
    if err then
      error(err)
    end
  end,
})
rex.bind("cmd+g", "lazygit_float")
