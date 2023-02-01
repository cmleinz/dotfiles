local wezterm = require 'wezterm'
local act = wezterm.action

return {
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },
  font = wezterm.font 'ComicCodeLigatures',
  color_scheme = "Gruvbox dark, medium (base16)",
  colors = {
    tab_bar = {
      background = '#3c3836',

      active_tab = {
        bg_color = '#1d2021',
        fg_color = '#fbf1c7',
      },

      inactive_tab = {
        bg_color = '#3c3836',
        fg_color = '#fbf1c7',
      },

      new_tab = {
        bg_color = '#282828',
        fg_color = '#d3869b',
      },
    },
  },
  leader = { key = ' ', mods = 'CTRL', timeout_milliseconds = 1000 },
  use_fancy_tab_bar = false,
  hide_tab_bar_if_only_one_tab = false,
  tab_bar_at_bottom = false,
  keys = {
    {
      key = 'v',
      mods = 'LEADER',
      action = act.SplitHorizontal {domain = 'CurrentPaneDomain' },
    },
    {
      key = 's',
      mods = 'LEADER',
      action = act.SplitVertical {domain = 'CurrentPaneDomain' },
    },
    {
      key = 'z',
      mods = 'LEADER',
      action = act.TogglePaneZoomState,
    },
    {
      key = 'w',
      mods = 'CTRL|LEADER',
      action = act.CloseCurrentPane { confirm = false },
    },
    {
      key = 'h',
      mods = 'LEADER',
      action = act.ActivatePaneDirection 'Left',
    },
    {
      key = 'j',
      mods = 'LEADER',
      action = act.ActivatePaneDirection 'Down',
    },
    {
      key = 'k',
      mods = 'LEADER',
      action = act.ActivatePaneDirection 'Up',
    },
    {
      key = 'l',
      mods = 'LEADER',
      action = act.ActivatePaneDirection 'Right',
    },
    {
      key = 'p',
      mods = 'LEADER',
      action = act.PaneSelect,
    }
  },
}

