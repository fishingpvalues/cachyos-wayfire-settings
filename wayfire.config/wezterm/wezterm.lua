local wezterm = require('wezterm')
local act = wezterm.action
local config = {}

-- Use the config_builder which will help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Load GitHub Dark theme
config.color_scheme_dirs = { 'colors' }
config.color_scheme = 'GitHub Dark'

-- SOTA Font configuration (harfbuzz, emoji/CJK fallback)
config.font = wezterm.font_with_fallback {
  'FiraCode Nerd Font',
  'CaskaydiaCove NF',
  'JetBrains Mono',
  'Cascadia Code',
  'DejaVu Sans Mono',       -- Linux fallback
  'Liberation Mono',        -- Linux fallback
  'Ubuntu Mono',            -- Ubuntu fallback
  'Noto Color Emoji',       -- Emoji fallback
  'Symbols Nerd Font Mono', -- Symbols fallback
  'Noto Sans CJK SC',       -- CJK fallback
}
config.font_size = 14
config.line_height = 1.1
config.font_shaper = 'Harfbuzz' -- Best ligature/emoji support

-- GPU rendering and performance (Linux optimized)
config.front_end = 'WebGpu' -- SOTA GPU rendering (if supported)
config.animation_fps = 30   -- Further reduced for better Linux performance
config.max_fps = 30         -- Further reduced for better Linux performance
config.adjust_window_size_when_changing_font_size = true

-- Modern window appearance (Linux optimized)
config.window_background_opacity = 0.85
config.window_decorations = 'TITLE | RESIZE'
config.window_padding = { left = 10, right = 10, top = 10, bottom = 10 }

-- Linux-specific window management
config.native_macos_fullscreen_mode = false  -- Disable macOS-specific features
config.win32_system_backdrop = 'Auto'        -- Disable Windows-specific features

-- SOTA clipboard: OSC 52 for remote/tmux/ssh (enabled by default in WezTerm)
-- See: https://wezfurlong.org/wezterm/config/clipboard.html
-- No extra config needed unless you want to restrict OSC 52

-- SOTA defaults
config.check_for_updates = true
config.enable_scroll_bar = true
config.scrollback_lines = 10000
config.window_close_confirmation = 'AlwaysPrompt'
config.automatically_reload_config = true
config.selection_word_boundary = " \t\n{}[]()\"'`,;:"

-- SOTA launch menu (Linux optimized)
local os_name = wezterm.target_triple
if os_name:find("windows") then
  config.default_prog = { 'pwsh.exe', '-NoLogo' }
  config.launch_menu = {
    { label = "PowerShell",     args = { "pwsh.exe", "-NoLogo" } },
    { label = "Command Prompt", args = { "cmd.exe" } },
    { label = "Git Bash",       args = { "bash.exe", "-i", "-l" } },
  }
elseif os_name:find("linux") then
  config.default_prog = { '/usr/bin/zsh' }
  config.launch_menu = {
    { label = "Zsh",  args = { "zsh", "-l" } },
    { label = "Bash", args = { "bash", "-l" } },
    { label = "Fish", args = { "fish", "-l" } },
    { label = "Nushell", args = { "nu", "-l" } },
  }
elseif os_name:find("darwin") then
  config.default_prog = { '/bin/zsh' }
  config.launch_menu = {
    { label = "Zsh",  args = { "zsh", "-l" } },
    { label = "Bash", args = { "bash", "-l" } },
    { label = "Fish", args = { "fish", "-l" } },
  }
end

-- SOTA SSH multiplexing
config.ssh_domains = wezterm.default_ssh_domains()

-- SOTA QuickSelect
config.quick_select_patterns = {
  "https?://\\S+",
  "/[\\w\\-./]+",
}

-- Tab bar appearance
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = false
config.tab_max_width = 25
config.show_tab_index_in_tab_bar = true
config.show_new_tab_button_in_tab_bar = true

-- Cursor configuration
config.default_cursor_style = 'SteadyBar'
config.cursor_blink_rate = 800
config.cursor_thickness = 2

-- Terminal bell
config.audible_bell = "Disabled"
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 75,
  target = 'CursorColor',
}

-- Disable annoying close confirmation
config.skip_close_confirmation_for_processes_named = {
  'bash', 'sh', 'zsh', 'fish', 'tmux', 'nu', 'cmd.exe', 'powershell.exe', 'pwsh.exe'
}

-- Linux-optimized mouse bindings
config.mouse_bindings = {
  -- Right click pastes from the clipboard
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = act.PasteFrom('Clipboard'),
  },
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.OpenLinkAtMouseCursor,
  },
}

-- Add tabline.wez plugin (with performance monitoring)
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
local battery = wezterm.plugin.require("https://github.com/rootiest/battery.wez")

-- Performance monitoring for plugins
local function check_plugin_performance()
    local start_time = wezterm.time.now()
    -- Plugin loading will happen here
    local end_time = wezterm.time.now()
    local load_time = (end_time - start_time) * 1000
    if load_time > 100 then
        wezterm.log.warn("Plugin loading took " .. load_time .. "ms - consider disabling plugins for better performance")
    end
end

battery.invert = true
battery.apply_to_config(config)

tabline.setup({
  options = {
    icons_enabled = true,
    theme = 'GitHub Dark',
    tabs_enabled = true,
    section_separators = { left = '│', right = '│' },
    component_separators = { left = '│', right = '│' },
    tab_separators = { left = '│', right = '│' },
  },
  sections = {
    tabline_a = {},
    tabline_b = { 'workspace', 'hostname' },
    tabline_c = { 'cwd', 'process' },
    tab_active = {
      'index',
      { 'cwd',    padding = { left = 0, right = 1 } },
      { 'zoomed', padding = 0 },
    },
    tab_inactive = { 'index', { 'process', padding = { left = 0, right = 1 } } },
    tabline_x = { 'ram', 'cpu', 'network' },
    tabline_y = { 'datetime' },
    tabline_z = { battery.get_battery_icons },
  },
  extensions = {},
})

tabline.apply_to_config(config)
config.tab_bar_at_bottom = true

-- Add modal.wezterm plugin
config.colors = wezterm.get_builtin_color_schemes()[config.color_scheme]
local modal = wezterm.plugin.require("https://github.com/MLFlexer/modal.wezterm")
modal.apply_to_config(config)

-- Add presentation.wez plugin
local presentation = wezterm.plugin.require("https://gitlab.com/xarvex/presentation.wez")
presentation.apply_to_config(config, {
  font_size_multiplier = 1.8,
  presentation = {
    keybind = { key = "o", mods = "CTRL|ALT" },
  },
  presentation_full = {
    keybind = { key = "o", mods = "CTRL|ALT|SHIFT" },
    font_size_multiplier = 2.4,
    font_weight = "Bold",
  },
})

-- =====================
-- SOTA Linux-Optimized Keybindings (Debian/Arch Compatible)
-- =====================
config.keys = {}

-- --- Pane Navigation (Vim style, Linux-optimized) ---
-- Ctrl+Alt+h/j/k/l: Move focus (Vim style)
local nav_keys = {
  { key = "h", mods = "CTRL|ALT", action = act.ActivatePaneDirection("Left") },   -- Ctrl+Alt+h: Focus left
  { key = "j", mods = "CTRL|ALT", action = act.ActivatePaneDirection("Down") },   -- Ctrl+Alt+j: Focus down
  { key = "k", mods = "CTRL|ALT", action = act.ActivatePaneDirection("Up") },     -- Ctrl+Alt+k: Focus up
  { key = "l", mods = "CTRL|ALT", action = act.ActivatePaneDirection("Right") },  -- Ctrl+Alt+l: Focus right
}

-- --- Pane Splitting (Linux-optimized) ---
-- Ctrl+Alt+S: Split horizontally (below)
-- Ctrl+Alt+V: Split vertically (right)
local split_keys = {
  { key = "s", mods = "CTRL|ALT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },   -- Ctrl+Alt+S: Split below
  { key = "v", mods = "CTRL|ALT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) }, -- Ctrl+Alt+V: Split right
}

-- --- Pane Zoom ---
-- Ctrl+Alt+Z: Toggle pane zoom
local zoom_keys = {
  { key = "z", mods = "CTRL|ALT", action = act.TogglePaneZoomState }, -- Ctrl+Alt+Z: Zoom/unzoom
}

-- --- Tab Management (Linux-optimized) ---
-- Ctrl+Alt+T: New tab
-- Ctrl+Alt+W: Close tab
-- Ctrl+Alt+Right/Left: Next/prev tab
local tab_keys = {
  { key = "t", mods = "CTRL|ALT", action = act.SpawnTab("CurrentPaneDomain") },    -- Ctrl+Alt+T: New tab
  { key = "w", mods = "CTRL|ALT", action = act.CloseCurrentTab({ confirm = true }) }, -- Ctrl+Alt+W: Close tab
  { key = "RightArrow", mods = "CTRL|ALT", action = act.ActivateTabRelative(1) },    -- Ctrl+Alt+→: Next tab
  { key = "LeftArrow", mods = "CTRL|ALT", action = act.ActivateTabRelative(-1) },    -- Ctrl+Alt+←: Previous tab
}

-- --- Pane Resizing ---
-- Ctrl+Alt+Shift+Arrows: Resize pane
local resize_keys = {
  { key = "LeftArrow",  mods = "CTRL|ALT|SHIFT", action = act.AdjustPaneSize({ "Left", 3 }) },
  { key = "DownArrow",  mods = "CTRL|ALT|SHIFT", action = act.AdjustPaneSize({ "Down", 3 }) },
  { key = "UpArrow",    mods = "CTRL|ALT|SHIFT", action = act.AdjustPaneSize({ "Up", 3 }) },
  { key = "RightArrow", mods = "CTRL|ALT|SHIFT", action = act.AdjustPaneSize({ "Right", 3 }) },
}

-- --- Dynamic font/opacity cycling ---
-- Ctrl+Alt+F: Cycle font size
-- Ctrl+Alt+G: Cycle font family
-- Ctrl+Alt+O: Cycle opacity
local dynamic_keys = {
  { key = 'F', mods = 'CTRL|ALT', action = wezterm.action.EmitEvent('cycle-font-size') },    -- Ctrl+Alt+F: Cycle font size
  { key = 'G', mods = 'CTRL|ALT', action = wezterm.action.EmitEvent('cycle-font-family') },  -- Ctrl+Alt+G: Cycle font family
  { key = 'O', mods = 'CTRL|ALT', action = wezterm.action.EmitEvent('cycle-opacity') },      -- Ctrl+Alt+O: Cycle opacity
}

-- --- Misc UX ---
-- Ctrl+Alt+Q: QuickSelect
-- Ctrl+Alt+C: Copy
local misc_keys = {
  { key = "q", mods = "CTRL|ALT", action = act.QuickSelect }, -- Ctrl+Alt+Q: QuickSelect
  { key = "c", mods = "CTRL|ALT", action = act.CopyTo("Clipboard") }, -- Ctrl+Alt+C: Copy
}

-- --- Pane Closing ---
-- Ctrl+Alt+X: Close current pane
local close_pane_keys = {
  { key = "x", mods = "CTRL|ALT", action = act.CloseCurrentPane { confirm = true } }, -- Ctrl+Alt+X: Close pane
}

-- --- Pane Picker/Swap ---
-- Ctrl+Alt+P: Pane picker
-- Ctrl+Alt+Shift+P: Swap with active pane
local pane_picker_keys = {
  { key = "p", mods = "CTRL|ALT", action = act.PaneSelect }, -- Ctrl+Alt+P: Pane picker
  { key = "P", mods = "CTRL|ALT|SHIFT", action = act.PaneSelect { mode = "SwapWithActive" } }, -- Ctrl+Alt+Shift+P: Swap pane
}

-- --- Command Palette ---
-- Ctrl+Alt+Space: Command palette
local command_palette_keys = {
  { key = " ", mods = "CTRL|ALT", action = act.ActivateCommandPalette }, -- Ctrl+Alt+Space: Command palette
}

-- --- Reload Config ---
-- Ctrl+Alt+R: Reload config
local reload_config_keys = {
  { key = "r", mods = "CTRL|ALT", action = act.ReloadConfiguration }, -- Ctrl+Alt+R: Reload config
}

-- --- Search Scrollback ---
-- Ctrl+Alt+Slash: Search scrollback
local search_scrollback_keys = {
  { key = "/", mods = "CTRL|ALT", action = act.Search { CaseInSensitiveString = "" } }, -- Ctrl+Alt+/ : Search scrollback
}

-- --- Workspace Management ---
-- Ctrl+Alt+N: Next workspace
-- Ctrl+Alt+Shift+N: Previous workspace
local workspace_keys = {
  { key = "n", mods = "CTRL|ALT", action = act.SwitchToWorkspace { name = "next" } }, -- Ctrl+Alt+N: Next workspace
  { key = "N", mods = "CTRL|ALT|SHIFT", action = act.SwitchToWorkspace { name = "prev" } }, -- Ctrl+Alt+Shift+N: Previous workspace
}

-- --- Tab Renaming ---
-- Ctrl+Alt+E: Rename current tab
local tab_rename_keys = {
  { key = "e", mods = "CTRL|ALT", action = act.PromptInputLine {
    description = "Rename Tab Title",
    action = wezterm.action_callback(function(window, pane, line)
      if line then
        window:active_tab():set_title(line)
      end
    end),
  } }, -- Ctrl+Alt+E: Rename tab
}

-- --- Scrollback Navigation ---
-- Ctrl+Alt+PageUp/PageDown: Page up/down
local scrollback_keys = {
  { key = "PageUp", mods = "CTRL|ALT", action = act.ScrollByPage(-1) }, -- Ctrl+Alt+PageUp: Page up
  { key = "PageDown", mods = "CTRL|ALT", action = act.ScrollByPage(1) }, -- Ctrl+Alt+PageDown: Page down
}

-- --- Linux-specific symbol input ---
-- Ctrl+Super+8: {
-- Ctrl+Super+9: }
-- Ctrl+Super+7: |
-- Ctrl+Super+/: \
-- Ctrl+Super+1: !
-- Ctrl+Super+2: @
-- Ctrl+Super+3: #
-- Ctrl+Super+4: $
-- Ctrl+Super+5: %
local symbol_keys = {
  { key = "8", mods = "CTRL|SUPER", action = act.SendString("{") },   -- Ctrl+Super+8: {
  { key = "9", mods = "CTRL|SUPER", action = act.SendString("}") },   -- Ctrl+Super+9: }
  { key = "7", mods = "CTRL|SUPER", action = act.SendString("|") },   -- Ctrl+Super+7: |
  { key = "/", mods = "CTRL|SUPER", action = act.SendString("\\") },  -- Ctrl+Super+/: \
  { key = "1", mods = "CTRL|SUPER", action = act.SendString("!") },   -- Ctrl+Super+1: !
  { key = "2", mods = "CTRL|SUPER", action = act.SendString("@") },   -- Ctrl+Super+2: @
  { key = "3", mods = "CTRL|SUPER", action = act.SendString("#") },   -- Ctrl+Super+3: #
  { key = "4", mods = "CTRL|SUPER", action = act.SendString("$") },   -- Ctrl+Super+4: $
  { key = "5", mods = "CTRL|SUPER", action = act.SendString("%") },   -- Ctrl+Super+5: %
}

-- --- Traditional Linux terminal shortcuts ---
-- Ctrl+Shift+C: Copy
-- Ctrl+Shift+V: Paste
-- Ctrl+Shift+T: New tab
-- Ctrl+Shift+W: Close tab
-- Ctrl+Shift+Right/Left: Next/prev tab
local traditional_keys = {
  { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") }, -- Ctrl+Shift+C: Copy
  { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") }, -- Ctrl+Shift+V: Paste
  { key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") }, -- Ctrl+Shift+T: New tab
  { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentTab({ confirm = true }) }, -- Ctrl+Shift+W: Close tab
  { key = "RightArrow", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(1) }, -- Ctrl+Shift+→: Next tab
  { key = "LeftArrow", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) }, -- Ctrl+Shift+←: Previous tab
}

-- --- Font size controls (Linux standard) ---
-- Ctrl+Plus: Increase font size
-- Ctrl+Minus: Decrease font size
-- Ctrl+0: Reset font size
local font_size_keys = {
  { key = "=", mods = "CTRL", action = act.IncreaseFontSize }, -- Ctrl+=: Increase font size
  { key = "-", mods = "CTRL", action = act.DecreaseFontSize }, -- Ctrl+-: Decrease font size
  { key = "0", mods = "CTRL", action = act.ResetFontSize }, -- Ctrl+0: Reset font size
}

-- --- Combine all key tables ---
for _, tbl in ipairs({nav_keys, split_keys, zoom_keys, tab_keys, resize_keys, dynamic_keys, misc_keys, close_pane_keys, pane_picker_keys, command_palette_keys, reload_config_keys, search_scrollback_keys, workspace_keys, tab_rename_keys, scrollback_keys, symbol_keys, traditional_keys, font_size_keys}) do
  for _, key in ipairs(tbl) do
    table.insert(config.keys, key)
  end
end

-- --- Mouse bindings (Linux-optimized) ---
-- Right click: Paste from clipboard
-- Ctrl+Click: Open link at mouse cursor
config.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = act.PasteFrom('Clipboard'),
  },
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.OpenLinkAtMouseCursor,
  },
}

-- Linux-specific settings
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

-- Dynamic font size cycling (Linux-optimized)
local font_size_steps = { 10, 12, 14, 16, 18, 20, 22, 24 }
local font_size_index = 3 -- Start at 14pt

wezterm.on('cycle-font-size', function(window, pane)
  font_size_index = (font_size_index % #font_size_steps) + 1
  window:set_config_overrides({ font_size = font_size_steps[font_size_index] })
  window:toast_notification('WezTerm', 'Font size: ' .. font_size_steps[font_size_index], nil, 4000)
end)

-- Dynamic font family cycling (Linux-optimized)
local font_families = {
  'FiraCode Nerd Font',
  'JetBrains Mono',
  'Cascadia Code',
  'DejaVu Sans Mono',
  'Liberation Mono',
}
local font_family_index = 1

wezterm.on('cycle-font-family', function(window, pane)
  font_family_index = (font_family_index % #font_families) + 1
  window:set_config_overrides({ font = wezterm.font_with_fallback({ font_families[font_family_index] }) })
  window:toast_notification('WezTerm', 'Font: ' .. font_families[font_family_index], nil, 4000)
end)

-- Dynamic opacity cycling (Linux-optimized)
local opacity_steps = { 0.7, 0.8, 0.85, 0.9, 0.95, 1.0 }
local opacity_index = 3 -- Start at 0.85

wezterm.on('cycle-opacity', function(window, pane)
  opacity_index = (opacity_index % #opacity_steps) + 1
  window:set_config_overrides({ window_background_opacity = opacity_steps[opacity_index] })
  window:toast_notification('WezTerm', 'Opacity: ' .. tostring(opacity_steps[opacity_index]), nil, 4000)
end)

return config 