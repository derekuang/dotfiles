local wezterm = require("wezterm")
local nf = wezterm.nerdfonts
local platform = {
  is_win = string.find(wezterm.target_triple, "windows") ~= nil,
  is_mac = string.find(wezterm.target_triple, "apple") ~= nil,
  is_linux = string.find(wezterm.target_triple, "linux") ~= nil,
}

-- events begin

-- format-tab-title
local GLYPH_NUMBER = {
  [1] = nf.md_numeric_1_circle,
  [2] = nf.md_numeric_2_circle,
  [3] = nf.md_numeric_3_circle,
  [4] = nf.md_numeric_4_circle,
  [5] = nf.md_numeric_5_circle,
  [6] = nf.md_numeric_6_circle,
  [7] = nf.md_numeric_7_circle,
  [8] = nf.md_numeric_8_circle,
  [9] = nf.md_numeric_9_circle,
  [10] = nf.md_numeric_9_plus_circle,
}
local GLYPH_SEMI_CIRCLE_LEFT = nf.ple_left_half_circle_thick
local GLYPH_SEMI_CIRCLE_RIGHT = nf.ple_right_half_circle_thick

local set_process_name = function(s)
  local a = string.gsub(s, "(.*[/\\])(.*)", "%2")
  return a:gsub("%.exe$", "")
end

local set_title = function(process_name, static_title, active_title)
  local title

  if static_title:len() > 0 then
    title = static_title
  elseif process_name:len() > 0 then
    title = process_name
  else
    title = active_title
  end

  return title
end

wezterm.on("format-tab-title", function(tab, _tabs, _panes, _config, _hover, max_width)
  local cells = {}
  local push = function(bg, fg, attribute, text)
    table.insert(cells, { Background = { Color = bg } })
    table.insert(cells, { Foreground = { Color = fg } })
    table.insert(cells, { Attribute = attribute })
    table.insert(cells, { Text = text })
  end

  local process_name = set_process_name(tab.active_pane.foreground_process_name)
  local title = set_title(process_name, tab.tab_title, tab.active_pane.title)

  local bg, fg
  local colors = {
    default = {
      bg = "#808080",
      fg = "#303446",
    },
    is_active = {
      bg = "#82AAFF",
      fg = "#303446",
    },
  }
  if tab.is_active then
    bg = colors.is_active.bg
    fg = colors.is_active.fg
  else
    bg = colors.default.bg
    fg = colors.default.fg
  end

  -- Left semi-circle
  push(fg, bg, { Intensity = "Bold" }, GLYPH_SEMI_CIRCLE_LEFT)

  -- Tab Index
  local tab_index
  if tab.tab_index < 9 then
    tab_index = tab.tab_index + 1
  else
    tab_index = 10
  end
  push(bg, fg, { Intensity = "Bold" }, " " .. GLYPH_NUMBER[tab_index] .. " ")

  -- Title
  push(bg, fg, { Intensity = "Bold" }, " " .. title)

  -- Right padding
  push(bg, fg, { Intensity = "Bold" }, " ")

  -- Right semi-circle
  push(fg, bg, { Intensity = "Bold" }, GLYPH_SEMI_CIRCLE_RIGHT)

  return cells
end)

-- events end

-- config

local act = wezterm.action

local mod = {}

if platform.is_mac then
  mod.SUPER = "SUPER"
  mod.SUPER_REV = "SUPER|CTRL"
elseif platform.is_win or platform.is_linux then
  mod.SUPER = "CTRL"
  mod.SUPER_REV = "CTRL|SHIFT"
end

local keys = {
  -- misc/useful --
  { key = "F11", mods = "NONE", action = act.ToggleFullScreen },
  { key = "F12", mods = "NONE", action = act.ShowDebugOverlay },
  { key = "p", mods = mod.SUPER_REV, action = act.ActivateCommandPalette },
  { key = "f", mods = mod.SUPER, action = act.Search({ CaseInSensitiveString = "" }) },

  -- copy/paste --
  { key = "c", mods = mod.SUPER_REV, action = act.CopyTo("Clipboard") },
  { key = "v", mods = mod.SUPER_REV, action = act.PasteFrom("Clipboard") },

  -- tabs --
  -- tabs: spawn+close
  { key = "t", mods = mod.SUPER, action = act.SpawnTab("DefaultDomain") },
  { key = "w", mods = mod.SUPER_REV, action = act.CloseCurrentTab({ confirm = false }) },

  -- tabs: navigation
  { key = "Tab", mods = mod.SUPER, action = act.ActivateLastTab },
  { key = "[", mods = mod.SUPER, action = act.ActivateTabRelative(-1) },
  { key = "]", mods = mod.SUPER, action = act.ActivateTabRelative(1) },
  { key = "[", mods = "ALT", action = act.MoveTabRelative(-1) },
  { key = "]", mods = "ALT", action = act.MoveTabRelative(1) },

  -- window --
  -- spawn windows
  { key = "n", mods = mod.SUPER, action = act.SpawnWindow },

  -- navigate windows
  { key = "1", mods = mod.SUPER, action = act.ActivateTab(0) },
  { key = "2", mods = mod.SUPER, action = act.ActivateTab(1) },
  { key = "3", mods = mod.SUPER, action = act.ActivateTab(2) },
  { key = "4", mods = mod.SUPER, action = act.ActivateTab(3) },
  { key = "5", mods = mod.SUPER, action = act.ActivateTab(4) },
  { key = "6", mods = mod.SUPER, action = act.ActivateTab(5) },
  { key = "7", mods = mod.SUPER, action = act.ActivateTab(6) },
  { key = "8", mods = mod.SUPER, action = act.ActivateTab(7) },
  { key = "9", mods = mod.SUPER, action = act.ActivateTab(8) },

  -- panes --
  -- panes: split panes
  {
    key = [[-]],
    mods = mod.SUPER,
    action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
  {
    key = [[\]],
    mods = mod.SUPER,
    action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "q",
    mods = mod.SUPER,
    action = act.CloseCurrentPane({ confirm = false }),
  },

  -- panes: zoom+close pane
  { key = "m", mods = mod.SUPER, action = act.TogglePaneZoomState },

  -- panes: navigation
  { key = "k", mods = mod.SUPER, action = act.ActivatePaneDirection("Up") },
  { key = "j", mods = mod.SUPER, action = act.ActivatePaneDirection("Down") },
  { key = "h", mods = mod.SUPER, action = act.ActivatePaneDirection("Left") },
  { key = "l", mods = mod.SUPER, action = act.ActivatePaneDirection("Right") },

  -- panes: resize
  { key = "UpArrow", mods = mod.SUPER_REV, action = act.AdjustPaneSize({ "Up", 1 }) },
  { key = "DownArrow", mods = mod.SUPER_REV, action = act.AdjustPaneSize({ "Down", 1 }) },
  { key = "LeftArrow", mods = mod.SUPER_REV, action = act.AdjustPaneSize({ "Left", 1 }) },
  { key = "RightArrow", mods = mod.SUPER_REV, action = act.AdjustPaneSize({ "Right", 1 }) },

  -- fonts --
  -- fonts: resize
  { key = "UpArrow", mods = mod.SUPER, action = act.IncreaseFontSize },
  { key = "DownArrow", mods = mod.SUPER, action = act.DecreaseFontSize },
  { key = "r", mods = mod.SUPER, action = act.ResetFontSize },

  -- key-tables --

  -- rename tab bar
  {
    key = "R",
    mods = "LEADER",
    action = act.PromptInputLine({
      description = "Enter new name for tab",
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },
}

return {
  -- appearance begin

  -- color scheme
  color_scheme = "Catppuccin Macchiato",

  -- background
  window_background_opacity = 0.9,

  -- window
  adjust_window_size_when_changing_font_size = false,
  window_decorations = "RESIZE",
  initial_cols = 180,
  initial_rows = 36,
  window_frame = {
    active_titlebar_bg = "#303446",
    inactive_titlebar_bg = "#303446",
  },
  inactive_pane_hsb = { saturation = 1.0, brightness = 0.6 },

  -- appearance end

  -- keybindings begin
  disable_default_key_bindings = true,
  leader = { key = "Space", mods = mod.SUPER },
  keys = keys,

  -- keybindings end

  -- fonts
  font = wezterm.font({
    family = "Maple Mono NF CN",
    harfbuzz_features = { "calt=0", "cv01", "cv34", "cv35", "cv37" },
  }),
  font_size = 10,

  -- general begin

  -- behaviours
  check_for_updates = false,

  -- paste behaviours
  canonicalize_pasted_newlines = "CarriageReturn",

  -- general end
}
