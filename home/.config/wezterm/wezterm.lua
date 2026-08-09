local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "rose-pine-moon"
config.font = wezterm.font("Hack Nerd Font")
config.font_size = 15.0
config.window_background_opacity = 0.8
config.macos_window_background_blur = 50
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

-- Workspaces are furniture, not accounts: the claude shim (~/.local/bin/claude)
-- routes accounts by folder, so a tab in the "wrong" workspace still gets the
-- right account. "work" = citycompass/bearings tabs; "personal" = ~/school etc.
config.default_workspace = "work"

-- Show the active workspace bottom-right (green = work, purple = personal).
wezterm.on("update-right-status", function(window, pane)
  local ws = window:active_workspace()
  window:set_right_status(wezterm.format({
    { Foreground = { Color = ws == "work" and "#a6d189" or "#c792ea" } },
    { Text = "  " .. ws .. "  " },
  }))
end)

config.keys = {
  {
    key = "F9",
    action = wezterm.action.SplitPane({
      direction = "Down",
      size = { Percent = 30 },
      command = { args = {
        os.getenv("HOME") .. "/Developer/ai-workflow-kit/bin/fleet",
        "-C", os.getenv("HOME") .. "/Developer/citycompass-civica",
        "watch", "15",
      } },
    }),
  },
  -- workspace switching: jump to work / personal, or list them all
  { key = "u", mods = "CMD|SHIFT", action = wezterm.action.SwitchToWorkspace({ name = "work" }) },
  { key = "p", mods = "CMD|SHIFT", action = wezterm.action.SwitchToWorkspace({ name = "personal", spawn = { cwd = os.getenv("HOME") .. "/school" } }) },
  { key = "l", mods = "CMD|SHIFT", action = wezterm.action.ShowLauncherArgs({ flags = "WORKSPACES" }) },
}

return config
