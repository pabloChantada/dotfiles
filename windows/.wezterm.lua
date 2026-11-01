-- ~/.wezterm.lua  (on Windows: C:\Users\<user>\.wezterm.lua)
-- Source of truth: dotfiles/windows/.wezterm.lua -> copied by wsl/sync-wezterm.sh
local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-------------------------------------------------------------------------------
-- WSL by default, starting in the Linux home
-------------------------------------------------------------------------------
config.wsl_domains = {
  { name = 'WSL:Ubuntu', distribution = 'Ubuntu', default_cwd = '~' },
}
config.default_domain = 'WSL:Ubuntu'

-------------------------------------------------------------------------------
-- Appearance
-------------------------------------------------------------------------------
-- Kanagawa Dragon: same palette as the Ghostty and Neovim configs
config.color_schemes = {
  ['Kanagawa Dragon'] = {
    foreground = '#c5c9c5',
    background = '#181820',
    cursor_bg = '#c8c093',
    cursor_fg = '#181820',
    cursor_border = '#c8c093',
    selection_bg = '#2d4f67',
    selection_fg = '#c8c093',
    split = '#393836',
    scrollbar_thumb = '#393836',
    ansi = { '#0d0c0c', '#c4746e', '#8a9a7b', '#c4b28a', '#8ba4b1', '#a292a3', '#8ea4a2', '#c8c093' },
    brights = { '#a6a69c', '#e46876', '#87a987', '#e6c384', '#7fb4ca', '#938aa9', '#7aa89f', '#c5c9c5' },
    tab_bar = {
      background = '#12120f',
      active_tab = { bg_color = '#282727', fg_color = '#c4b28a', intensity = 'Bold' },
      inactive_tab = { bg_color = '#12120f', fg_color = '#737c73' },
      inactive_tab_hover = { bg_color = '#1d1c19', fg_color = '#c5c9c5' },
      new_tab = { bg_color = '#12120f', fg_color = '#737c73' },
      new_tab_hover = { bg_color = '#1d1c19', fg_color = '#c5c9c5' },
    },
  },
}
config.color_scheme = 'Kanagawa Dragon'
config.font = wezterm.font_with_fallback { 'JetBrainsMono Nerd Font', 'JetBrains Mono' }
config.font_size = 12
config.line_height = 1.05

config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.window_padding = { left = 8, right = 8, top = 6, bottom = 4 }
config.window_background_opacity = 0.9 -- same as Ghostty; Neovim is transparent and shows this background
-- config.win32_system_backdrop = 'Acrylic' -- Windows 11 style blur (optional)
config.initial_cols = 140
config.initial_rows = 38

config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.tab_max_width = 32
config.hide_tab_bar_if_only_one_tab = false

config.inactive_pane_hsb = { saturation = 0.85, brightness = 0.7 }
config.audible_bell = 'Disabled'
config.scrollback_lines = 10000
config.max_fps = 120

-- Kitty keyboard protocol: lets Neovim receive Ctrl+1..4 (Harpoon),
-- Ctrl+Shift+letter, etc. Only enabled when the app requests it.
config.enable_kitty_keyboard = true

-------------------------------------------------------------------------------
-- tmux-style keys. Leader = Ctrl+a (press Ctrl+a, then the key)
-- Designed for a Spanish keyboard: no | or \, which need AltGr.
-------------------------------------------------------------------------------
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

config.keys = {
  -- Panes
  { key = 'v', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } }, -- side by side
  { key = 's', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },   -- stacked
  { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },
  { key = 'r', mods = 'LEADER', action = act.ActivateKeyTable { name = 'resize_pane', one_shot = false } },

  -- Tabs
  { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
  { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
  { key = 't', mods = 'LEADER', action = act.ShowTabNavigator },

  -- Dev layout: Claude Code in a pane on the right (35%)
  {
    key = 'd',
    mods = 'LEADER',
    action = act.SplitPane {
      direction = 'Right',
      size = { Percent = 35 },
      command = { args = { 'zsh', '-lic', 'claude; exec zsh' }, domain = 'CurrentPaneDomain' },
    },
  },

  -- WezTerm command palette
  { key = 'Space', mods = 'LEADER', action = act.ActivateCommandPalette },

  -- Ctrl+a twice sends a literal Ctrl+a (start of line in zsh)
  { key = 'a', mods = 'LEADER|CTRL', action = act.SendKey { key = 'a', mods = 'CTRL' } },
}

-- Leader + number: go to tab N
for i = 1, 9 do
  table.insert(config.keys, { key = tostring(i), mods = 'LEADER', action = act.ActivateTab(i - 1) })
end

config.key_tables = {
  resize_pane = {
    { key = 'h', action = act.AdjustPaneSize { 'Left', 3 } },
    { key = 'j', action = act.AdjustPaneSize { 'Down', 3 } },
    { key = 'k', action = act.AdjustPaneSize { 'Up', 3 } },
    { key = 'l', action = act.AdjustPaneSize { 'Right', 3 } },
    { key = 'Escape', action = 'PopKeyTable' },
    { key = 'Enter', action = 'PopKeyTable' },
  },
}

-------------------------------------------------------------------------------
-- Status bar indicator when leader or resize mode is active
-------------------------------------------------------------------------------
wezterm.on('update-right-status', function(window, _)
  local text = ''
  if window:active_key_table() == 'resize_pane' then
    text = ' RESIZE '
  elseif window:leader_is_active() then
    text = ' LEADER '
  end
  window:set_right_status(wezterm.format {
    { Background = { Color = '#c4b28a' } },
    { Foreground = { Color = '#181820' } },
    { Text = text },
  })
end)

return config
