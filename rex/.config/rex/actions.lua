local M = {}

local terminal = "com.superlogical.terminal"

-- the focused pane's foreground process, with its name, pid and cwd
function M.foreground(ctx)
  local ok, proc = pcall(rex.block.call, terminal, "process", { block_id = ctx.block_id })
  return ok and proc and proc.foreground or nil
end

-- the focused pane's directory: the foreground process's cwd (follows nvim's :cd),
-- else what the shell last reported
local function focused_cwd(ctx)
  local fg = M.foreground(ctx)
  if fg and fg.cwd then
    return fg.cwd
  end
  local ok, pwd = pcall(rex.block.call, terminal, "pwd", { block_id = ctx.block_id })
  if ok and pwd and pwd.pwd then
    return (pwd.pwd:gsub("^file://[^/]*", ""))
  end
end

-- the session's floating layer holding a block labelled label, if there is one
local function float_layer(ctx, label)
  local view = rex.call("session.view", { session_id = ctx.session_id })
  for _, window in ipairs(view.windows or {}) do
    for _, layer in ipairs(window.layers or {}) do
      for _, block in ipairs(layer.kind ~= "tiled" and layer.blocks or {}) do
        if block.label == label then
          return layer.layer_id
        end
      end
    end
  end
end

-- a palette action that toggles a floating pane labelled spec.name in the
-- focused pane's directory, running spec.command or a shell
-- bounds is x, y, w, h as fractions of the window, nearly full-window by default
local function float(spec)
  rex.action({
    name = spec.name,
    title = spec.title,
    keywords = spec.keywords,
    run = function(ctx)
      local layer_id = float_layer(ctx, spec.name)
      if layer_id then
        rex.session.close_layer({ session_id = ctx.session_id, layer_id = layer_id })
        return
      end
      local _, err = rex.session.new_layer({
        session_id = ctx.session_id,
        bounds = spec.bounds or { 0.05, 0.05, 0.9, 0.9 },
        layout = rex.layout.block({
          flavor = terminal .. ".shell",
          label = spec.name,
          options = { command = spec.command, cwd = focused_cwd(ctx), interactive = spec.command ~= nil },
        }),
        focus = true,
      })
      if err then
        error(err)
      end
    end,
  })
end

float({
  name = "scratch_float",
  title = "Toggle Scratch Terminal",
  keywords = "scratch terminal float",
})

float({
  name = "lazygit_float",
  title = "Toggle Lazygit",
  keywords = "git lazygit float",
  command = { "lazygit" },
})

return M
