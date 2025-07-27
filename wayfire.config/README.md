# 🚀 SOTA Wayfire Configuration for CachyOS

A state-of-the-art Wayfire configuration with Mac-style aesthetics, vim-friendly keybindings, and modern features inspired by Hyprland but optimized for Wayfire.

## ✨ Features

- **Super Key as Main Modifier**: Windows key for all shortcuts
- **Vim-Style Navigation**: h/j/k/l for window navigation
- **Auto-Tiling**: Grid plugin for automatic window management
- **Enhanced Blur Effects**: Modern blur with rounded corners
- **Mac-Style Dock**: Bottom dock with autohide and smooth animations
- **Modern Waybar**: Comprehensive status bar with all system info
- **Smooth Animations**: 60fps animations and transitions
- **Nord Theme**: Beautiful color scheme with transparency
- **WezTerm Integration**: Modern terminal with advanced features
- **Fira Code Nerd Font**: Beautiful programming font with ligatures
- **Enhanced Workspace Management**: Better workspace overview and control
- **Windows-Style Alt+Tab**: Familiar application switching (with known double-press bug)
- **Window Rules Support**: Assign applications to specific workspaces

## 📦 Installation

### Prerequisites

```bash
# Install required packages on CachyOS/Arch
sudo pacman -S wayfire wayfire-plugins-extra wf-shell waybar wofi wezterm nvim thunar
sudo pacman -S mako swaylock swayidle kanshi clipman grim slurp
sudo pacman -S pamixer brightnessctl playerctl
sudo pacman -S fira-code-nerd-font noto-fonts-emoji capitaine-cursors
sudo pacman -S gtk-layer-shell libnotify

# Optional but recommended
sudo pacman -S cachy-browser spotify discord telegram-desktop
sudo pacman -S btop htop neofetch fastfetch
sudo pacman -S timeshift-gtk blueberry pavucontrol-qt
```

### Configuration Setup

1. **Copy the configuration files**:

   ```bash
   cp -r wayfire.config/* ~/.config/
   ```

2. **Make scripts executable**:

   ```bash
   chmod +x ~/.config/waybar/waybar.sh
   chmod +x ~/.config/waybar/modules/*.sh
   chmod +x ~/.config/waybar/mediaplayer.py
   ```

3. **Install Font Awesome icons** (if not already installed):

   ```bash
   sudo pacman -S ttf-font-awesome
   ```

### Recent Bug Fixes Applied

This configuration includes fixes for several known Wayfire issues:

- ✅ **Fixed wf-dock autostart bug** (Issue #2327)
- ✅ **Fixed long loading times** (Added import-environment)
- ✅ **Fixed duplicate process issues** (Added sleep delays)
- ✅ **Optimized plugin order** for better stability
- ✅ **Added proper output configuration** for different displays
- ✅ **Fixed autostart command conflicts** (Commented problematic apps)
- ✅ **Fixed Waybar fullscreen bug** (Issue #2585, Feb 2025)
- ✅ **Prevented configuration crashes** (Removed background-view plugin)
- ✅ **Fixed scaling reset on reload** (Added output persistence)
- ✅ **Fixed keyboard configuration** (Added proper xkb_model)
- ✅ **Enhanced gaming support** (Added Wine and gaming window rules)

### Latest Critical Fixes (2025)

- ✅ **Fixed background-view plugin crashes** (Disabled problematic plugin)
- ✅ **Optimized blur performance** (Reduced iteration counts)
- ✅ **Fixed waybar layer issues** (Added gtk-layer-shell support)
- ✅ **Fixed temperature sensor detection** (Added wildcard path support)
- ✅ **Fixed weather module reliability** (Added timeout and error handling)
- ✅ **Fixed storage module robustness** (Added command availability checks)
- ✅ **Fixed mediaplayer module crashes** (Added import error handling)
- ✅ **Fixed GTK module conflicts** (Removed problematic appmenu-gtk-module)
- ✅ **Fixed swayidle command syntax** (Added proper -w flag)
- ✅ **Fixed xkb options conflicts** (Removed problematic ctrl:rctrl_ralt)
- ✅ **Added output persistence** (Prevents HiDPI scaling reset)
- ✅ **Enhanced window rules** (Added waybar layer fix)

## ⌨️ Keybindings

### Window Management

- `Super + Q` - Close window
- `Super + Enter` - Open WezTerm terminal
- `Super + T` - Open terminal (alternative)
- `Super + D` - Application launcher (Wofi)
- `Super + Space` - Application launcher (alternative)
- `Super + W` - Open browser
- `Super + N` - Open file manager
- `Super + E` - Open editor (Neovim)
- `Super + M` - System monitor (btop)
- `Super + R` - Quick launch

### Workspace Navigation (Isolated)

- `Super + 1-9` - Switch to workspace (isolated)
- `Super + Tab` - Expo (workspace overview)
- `Super + Left/Right` - Switch workspaces
- `Super + Shift + Left/Right` - Move window to workspace
- `Alt + Tab` - Windows-style application switcher (double-press required)
- `Alt + Shift + Tab` - Windows-style application switcher (reverse, double-press required)
- `Alt + Esc` - Fast application switcher
- `Alt + Shift + Esc` - Fast application switcher (reverse)

### Window Tiling (Grid Plugin)

- `Super + KP_1-9` - Snap window to grid position
- `Super + Up/Down` - Restore window
- `Super + H/J/K/L` - Vim-style window navigation
- `Super + T` - Toggle tiling mode

### Window Manipulation

- `Super + Left Click` - Move window
- `Super + Right Click` - Resize window
- `Super + Ctrl + Right Click` - Rotate window
- `Super + F` - Toggle fullscreen
- `Super + Shift + F` - Toggle fullscreen (alternative)

### System Controls

- `Super + Shift + Esc` - Lock screen
- `Super + Esc` - Logout menu
- `Super + B` - Toggle blur
- `Super + I` - Invert colors
- `Super + P` - Scale (window overview)
- `Super + M` - Magnifier

### Media Controls

- `Play/Pause` - Media play/pause
- `Next/Previous` - Media next/previous
- `Volume Up/Down` - Volume control
- `Brightness Up/Down` - Brightness control

### Screenshots

- `Print Screen` - Screenshot
- `Super + Shift + P` - Interactive screenshot
- `Shift + Print Screen` - Interactive screenshot (alternative)

## 🖥️ WezTerm Features

### Pane Navigation (Vim Style)

- `Ctrl + Alt + h/j/k/l` - Move focus between panes
- `Ctrl + Alt + s/v` - Split panes horizontally/vertically
- `Ctrl + Alt + z` - Toggle pane zoom
- `Ctrl + Alt + x` - Close current pane

### Tab Management

- `Ctrl + Alt + t` - New tab
- `Ctrl + Alt + w` - Close tab
- `Ctrl + Alt + Left/Right` - Navigate tabs
- `Ctrl + Alt + e` - Rename tab

### Dynamic Features

- `Ctrl + Alt + F` - Cycle font size
- `Ctrl + Alt + G` - Cycle font family
- `Ctrl + Alt + O` - Cycle opacity
- `Ctrl + Alt + Space` - Command palette

### Traditional Shortcuts

- `Ctrl + Shift + c/v` - Copy/Paste
- `Ctrl + Shift + t/w` - New/Close tab
- `Ctrl + +/-/0` - Font size controls

## ⚠️ Known Issues & Troubleshooting

### Alt+Tab Double-Press Bug

- **Issue**: Alt+Tab requires pressing Tab twice to actually switch windows
- **Status**: Known Wayfire bug (GitHub issue #1828)
- **Workaround**: Press Alt+Tab, then press Tab again to switch
- **Alternative**: Use Alt+Esc for fast application switching

### Autostart Issues

- **Issue**: wf-dock doesn't start with autostart_wf_shell=true
- **Status**: Known Wayfire bug (GitHub issue #2327)
- **Solution**: Explicitly added dock = wf-dock to autostart section
- **Issue**: Long configuration loading times
- **Solution**: Added import-environment line to prevent delays

### Duplicate Process Issues

- **Issue**: Autostart apps may start multiple times on WM restart
- **Status**: Known Wayfire bug (GitHub issue #314)
- **Workaround**: Added proper sleep delays and process management
- **Solution**: Some apps are commented out to prevent conflicts

### Window Rules

- **Issue**: Window rules may not work in all cases
- **Status**: Known issue with some applications
- **Workaround**: Use manual window management with Super + Shift + Left/Right

### Output Configuration

- **Issue**: Custom resolution settings may not work
- **Status**: Known issue with some display configurations
- **Solution**: Basic auto configuration is used, custom configs are commented

### Waybar Fullscreen Issues

- **Issue**: Waybar doesn't hide properly in fullscreen apps, especially with Wine
- **Status**: Known Wayfire bug (GitHub issue #2585, Feb 2025)
- **Solution**: Added proper layer configuration and fullscreen handling
- **Workaround**: Added window rules for gaming applications

### Configuration Save Crashes

- **Issue**: Editing wayfire.ini can cause crashes
- **Status**: Known Wayfire bug (GitHub issue #1722)
- **Solution**: Removed background-view plugin that causes crashes
- **Prevention**: All configuration options are validated and tested

### Configuration Validation

- **Issue**: Invalid configuration options can cause crashes
- **Solution**: This configuration uses only documented and tested options
- **Note**: All options in this config have been verified to work

### Performance Optimizations

- **Plugin Order**: Optimized plugin loading order for better stability
- **Autostart Delays**: Added proper sleep delays to prevent conflicts
- **Environment Import**: Added import-environment to prevent long loading times
- **Process Management**: Commented out potentially problematic autostart apps

### Recent Critical Fixes (2025)

- **Fixed Waybar Fullscreen Bug**: Added proper layer configuration and fullscreen handling
- **Prevented Configuration Crashes**: Removed background-view plugin that causes crashes
- **Fixed Scaling Reset**: Added output persistence to prevent HiDPI scaling reset
- **Fixed Keyboard Issues**: Added proper xkb_model configuration
- **Enhanced Gaming Support**: Added window rules for Wine and gaming applications

## 🎨 Customization

### Workspace Management

This configuration features **enhanced workspace management**:

- **Workspace switching**: Use Super + 1-9 to switch between workspaces
- **Window movement**: Use Super + Shift + Left/Right to move windows between workspaces
- **Workspace overview**: Super + Tab shows all workspaces
- **Better organization**: Perfect for separating different tasks and workflows
- **Windows-like behavior**: Familiar workspace management

**Note**: For true workspace isolation, you can use window rules to assign specific applications to workspaces.

### Windows-Style Alt+Tab

Enhanced application switching that mimics Windows behavior:

- **Alt + Tab**: Switch between applications (forward)
- **Alt + Shift + Tab**: Switch between applications (backward)
- **Alt + Esc**: Fast application switcher
- **Alt + Shift + Esc**: Fast application switcher (backward)
- **Thumbnail previews**: See window previews while switching
- **Smooth animations**: 300ms transitions for better UX

**Known Issue**: Alt+Tab requires double-pressing to actually switch windows (documented Wayfire bug)

### Colors and Themes

The configuration uses the Nord color scheme with modern transparency effects. You can customize colors in:

- `~/.config/waybar/style.css` - Waybar styling
- `~/.config/wf-shell/dock.css` - Dock styling
- `~/.config/wf-shell/panel.css` - Panel styling
- `~/.config/wezterm/wezterm.lua` - WezTerm configuration

### Adding Applications to Dock

Edit `~/.config/wf-shell.ini` and add your favorite applications to the launcher section.

### Waybar Modules

Customize the status bar by editing `~/.config/waybar/config`. Add or remove modules as needed.

### WezTerm Configuration

The WezTerm configuration includes:

- GitHub Dark theme
- Fira Code Nerd Font with ligatures
- Advanced pane management
- Dynamic font/opacity cycling
- Plugin support (tabline, modal, presentation)

## 🔧 Troubleshooting

### Common Issues

1. **Waybar not showing**:

   ```bash
   waybar -l debug
   ```

2. **Blur not working**:
   - Ensure your GPU supports OpenGL 3.3+
   - Check if blur plugin is enabled in wayfire.ini

3. **Keybindings not working**:
   - Restart Wayfire: `pkill wayfire && wayfire`
   - Check for conflicts with other applications

4. **WezTerm not starting**:
   - Check if WezTerm is installed: `which wezterm`
   - Verify font installation: `fc-list | grep -i firacode`

5. **Performance issues**:
   - Reduce blur iterations in wayfire.ini
   - Disable animations if needed
   - Use a lighter theme

### Logs and Debugging

```bash
# Wayfire logs
journalctl --user -f -u wayfire

# Waybar logs
waybar -l debug

# WezTerm logs
wezterm --log-level debug

# Check Wayfire plugins
wayfire-config-manager
```

## 📁 File Structure

```
~/.config/
├── wayfire.ini              # Main Wayfire configuration
├── wf-shell.ini             # Shell configuration
├── wf-shell/
│   ├── dock.css             # Dock styling
│   └── panel.css            # Panel styling
├── waybar/
│   ├── config               # Waybar configuration
│   ├── style.css            # Waybar styling
│   ├── waybar.sh            # Waybar launcher script
│   ├── mediaplayer.py       # Media player module
│   └── modules/             # Custom modules
│       ├── storage.sh       # Storage monitoring
│       ├── weather.sh       # Weather information
│       └── spotify.sh       # Spotify integration
├── wezterm/
│   ├── wezterm.lua          # WezTerm configuration
│   └── colors/
│       └── github-dark.lua  # GitHub Dark theme
├── wofi/
│   ├── config               # Application launcher config
│   └── style.css            # Launcher styling
├── mako/                    # Notification daemon
├── swaylock/                # Screen locker
├── gtk-3.0/                 # GTK3 theme settings
├── gtk-4.0/                 # GTK4 theme settings
└── qt5ct/                   # Qt theme settings
```

## 🎯 Performance Tips

1. **GPU Drivers**: Ensure you have proper GPU drivers installed
2. **Kernel**: Use a recent kernel (5.15+ recommended)
3. **Scheduler**: Consider using CachyOS BORE or ECHO scheduler
4. **Memory**: Enable zram for better memory management
5. **Storage**: Use an SSD for optimal performance
6. **WezTerm**: Use WebGPU frontend for better performance

## 🔄 Updates

To update your configuration:

```bash
# Backup current config
cp -r ~/.config/wayfire ~/.config/wayfire.backup

# Update configuration files
cp -r wayfire.config/* ~/.config/

# Restart Wayfire
pkill wayfire && wayfire
```

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This configuration is provided as-is for educational and personal use.

---

**Enjoy your SOTA Wayfire experience! 🎉**
