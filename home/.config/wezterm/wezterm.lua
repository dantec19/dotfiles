local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "rose-pine-moon"
config.font = wezterm.font("Hack Nerd Font")
config.font_size = 15.0
config.window_background_opacity = 0.8
config.macos_window_background_blur = 50
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"
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
}

return config
