#!/bin/bash

# 🚀 SOTA Wayfire Configuration Installer for CachyOS (Enhanced v2.1)
# This script installs all necessary packages and configurations with comprehensive error handling

set -euo pipefail  # Enhanced error handling

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_critical() {
    echo -e "${PURPLE}[CRITICAL]${NC} $1"
}

log_debug() {
    echo -e "${CYAN}[DEBUG]${NC} $1"
}

# Error handling function
handle_error() {
    local exit_code=$?
    local line_number=$1
    log_error "Error occurred in line $line_number (exit code: $exit_code)"
    log_error "Please check the error and try again"
    exit $exit_code
}

# Set error trap
trap 'handle_error $LINENO' ERR

# Security check function
security_check() {
    log_info "Performing security checks..."
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        exit 1
    fi
    
    # Check for dangerous environment variables
    if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
        log_warning "WAYLAND_DISPLAY is set: $WAYLAND_DISPLAY"
    fi
    
    # Check for suspicious files
    if [[ -f "/tmp/wayfire_install" ]]; then
        log_warning "Found suspicious file: /tmp/wayfire_install"
    fi
    
    log_success "Security checks passed"
}

# Version compatibility check
check_version_compatibility() {
    log_info "Checking version compatibility..."
    
    # Check Wayfire version
    if command -v wayfire &> /dev/null; then
        local wayfire_version=$(wayfire --version 2>/dev/null | head -1 || echo "unknown")
        log_info "Detected Wayfire version: $wayfire_version"
        
        if [[ "$wayfire_version" == *"0.8"* ]]; then
            log_warning "⚠️  CRITICAL: CachyOS is using Wayfire 0.8.x while upstream is at 0.11"
            log_warning "This may cause compatibility issues with wlroots 0.18"
            log_warning "Consider waiting for CachyOS to update Wayfire package"
        fi
    else
        log_info "Wayfire not installed yet"
    fi
    
    # Check wlroots version
    if command -v pkg-config &> /dev/null; then
        local wlroots_version=$(pkg-config --modversion wlroots 2>/dev/null || echo "unknown")
        log_info "Detected wlroots version: $wlroots_version"
        
        if [[ "$wlroots_version" == *"0.18"* ]]; then
            log_warning "⚠️  CRITICAL: wlroots 0.18 detected - may have compatibility issues with Wayfire 0.8"
        fi
    fi
    
    # Check CachyOS version
    if [[ -f "/etc/os-release" ]]; then
        local os_info=$(grep -E "^(NAME|VERSION)" /etc/os-release | head -2)
        log_info "OS Information:"
        echo "$os_info" | while read line; do
            log_info "  $line"
        done
    fi
    
    log_success "Version compatibility check completed"
}

# Dependency check function
check_dependencies() {
    log_info "Checking system dependencies..."
    
    local missing_deps=()
    local critical_deps=("pacman" "sudo" "bash" "curl" "wget")
    local optional_deps=("git" "python" "pip" "node" "npm")
    
    # Check critical dependencies
    for dep in "${critical_deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    # Check optional dependencies
    for dep in "${optional_deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            log_warning "Optional dependency missing: $dep"
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing critical dependencies: ${missing_deps[*]}"
        log_error "Please install missing dependencies and try again"
        exit 1
    fi
    
    log_success "All critical dependencies found"
}

# Check if we're on an Arch-based system
check_arch_system() {
    log_info "Checking system compatibility..."
    
    if ! command -v pacman &> /dev/null; then
        log_error "This script is designed for Arch-based systems (CachyOS, Arch Linux, etc.)"
        log_error "Detected package manager: $(command -v apt-get 2>/dev/null || command -v dnf 2>/dev/null || command -v zypper 2>/dev/null || echo "unknown")"
        exit 1
    fi
    
    # Check if it's actually CachyOS
    if [[ -f "/etc/os-release" ]] && grep -q "CachyOS" /etc/os-release; then
        log_success "CachyOS detected - optimal compatibility"
    else
        log_warning "Not CachyOS - some optimizations may not apply"
    fi
    
    log_success "System compatibility check passed"
}

# Backup function
create_backup() {
    log_info "Creating backup of existing configuration..."
    
    local backup_dir="$HOME/.config/wayfire.backup.$(date +%Y%m%d_%H%M%S)"
    
    if [[ -d "$HOME/.config/wayfire" ]]; then
        if cp -r "$HOME/.config/wayfire" "$backup_dir"; then
            log_success "Backup created: $backup_dir"
        else
            log_error "Failed to create backup"
            exit 1
        fi
    else
        log_info "No existing Wayfire configuration found"
    fi
    
    # Backup other relevant configs
    local configs_to_backup=("wayfire.ini" "wf-shell.ini" "waybar" "wezterm" "wofi")
    for config in "${configs_to_backup[@]}"; do
        if [[ -e "$HOME/.config/$config" ]]; then
            local config_backup="$HOME/.config/${config}.backup.$(date +%Y%m%d_%H%M%S)"
            if cp -r "$HOME/.config/$config" "$config_backup"; then
                log_info "Backed up: $config"
            fi
        fi
    done
}

# Install packages with error handling
install_packages() {
    log_info "Installing required packages..."
    
    # Update system first
    log_info "Updating system packages..."
    if ! sudo pacman -Syu --noconfirm; then
        log_error "Failed to update system packages"
        exit 1
    fi
    
    # Core Wayfire packages
    local core_packages=(
        "wayfire"
        "wayfire-plugins-extra"
        "wf-shell"
        "waybar"
        "wofi"
        "wezterm"
        "nvim"
        "thunar"
    )
    
    # System utilities
    local system_packages=(
        "mako"
        "swaylock"
        "swayidle"
        "kanshi"
        "clipman"
        "grim"
        "slurp"
        "pamixer"
        "brightnessctl"
        "playerctl"
    )
    
    # Fonts and themes
    local font_packages=(
        "fira-code-nerd-font"
        "noto-fonts-emoji"
        "capitaine-cursors"
        "ttf-font-awesome"
    )
    
    # Additional dependencies
    local deps_packages=(
        "gtk-layer-shell"
        "libnotify"
        "python-gobject"
        "python-requests"
    )
    
    # Optional but recommended packages
    local optional_packages=(
        "cachy-browser"
        "spotify"
        "discord"
        "telegram-desktop"
        "btop"
        "htop"
        "neofetch"
        "fastfetch"
        "timeshift-gtk"
        "blueberry"
        "pavucontrol-qt"
        "gsimplecal"
        "wlogout"
    )
    
    # Install packages with error handling
    local all_packages=("${core_packages[@]}" "${system_packages[@]}" "${font_packages[@]}" "${deps_packages[@]}")
    
    log_info "Installing core packages..."
    if ! sudo pacman -S --noconfirm "${all_packages[@]}"; then
        log_error "Failed to install core packages"
        exit 1
    fi
    
    log_info "Installing optional packages..."
    if ! sudo pacman -S --noconfirm "${optional_packages[@]}"; then
        log_warning "Some optional packages failed to install - continuing anyway"
    fi
    
    log_success "All packages installed successfully!"
}

# Copy configuration files with validation
copy_configurations() {
    log_info "Copying configuration files..."
    
    # Validate source directory
    if [[ ! -d "wayfire.config" ]]; then
        log_error "wayfire.config directory not found"
        exit 1
    fi
    
    # Copy with error handling
    if ! cp -r wayfire.config/* "$HOME/.config/"; then
        log_error "Failed to copy configuration files"
        exit 1
    fi
    
    log_success "Configuration files copied successfully"
}

# Make scripts executable with security checks
make_executable() {
    log_info "Making scripts executable..."
    
    local scripts=(
        "$HOME/.config/waybar/waybar.sh"
        "$HOME/.config/waybar/modules/storage.sh"
        "$HOME/.config/waybar/modules/weather.sh"
        "$HOME/.config/waybar/modules/spotify.sh"
        "$HOME/.config/waybar/mediaplayer.py"
    )
    
    for script in "${scripts[@]}"; do
        if [[ -f "$script" ]]; then
            if chmod +x "$script"; then
                log_info "Made executable: $(basename "$script")"
            else
                log_warning "Failed to make executable: $(basename "$script")"
            fi
        else
            log_warning "Script not found: $(basename "$script")"
        fi
    done
}

# Create necessary directories
create_directories() {
    log_info "Creating necessary directories..."
    
    local directories=(
        "$HOME/.cache/waybar"
        "$HOME/.cache/rbn"
        "$HOME/Pictures/screenshots"
        "$HOME/.local/share/applications"
        "$HOME/.config/autostart"
    )
    
    for dir in "${directories[@]}"; do
        if mkdir -p "$dir"; then
            log_info "Created directory: $dir"
        else
            log_warning "Failed to create directory: $dir"
        fi
    done
}

# Set up environment variables
setup_environment() {
    log_info "Setting up environment variables..."
    
    local bashrc="$HOME/.bashrc"
    local zshrc="$HOME/.zshrc"
    
    # Function to add environment variable if not present
    add_env_var() {
        local file="$1"
        local var="$2"
        local value="$3"
        
        if [[ -f "$file" ]] && ! grep -q "$var" "$file"; then
            echo "export $var=$value" >> "$file"
            log_info "Added $var to $file"
        fi
    }
    
    # Add environment variables to bashrc
    add_env_var "$bashrc" "WAYLAND_DISPLAY" "wayland-1"
    add_env_var "$bashrc" "XDG_CURRENT_DESKTOP" "Wayfire"
    
    # Add to zshrc if it exists
    if [[ -f "$zshrc" ]]; then
        add_env_var "$zshrc" "WAYLAND_DISPLAY" "wayland-1"
        add_env_var "$zshrc" "XDG_CURRENT_DESKTOP" "Wayfire"
    fi
}

# Create desktop entry for Wayfire
create_desktop_entry() {
    log_info "Creating desktop entry for Wayfire..."
    
    local desktop_file="$HOME/.local/share/applications/wayfire.desktop"
    
    cat > "$desktop_file" << 'EOF'
[Desktop Entry]
Name=Wayfire
Comment=Wayland compositor
Exec=wayfire
Type=Application
Categories=System;Settings;
Keywords=wayland;compositor;window manager;
EOF
    
    if [[ -f "$desktop_file" ]]; then
        log_success "Desktop entry created: $desktop_file"
    else
        log_error "Failed to create desktop entry"
    fi
}

# Set up autostart with enhanced error handling
setup_autostart() {
    log_info "Setting up autostart..."
    
    local autostart_script="$HOME/.config/autostart/wayfire-autostart.sh"
    
    cat > "$autostart_script" << 'EOF'
#!/bin/bash
# Enhanced Wayfire autostart script with error handling

set -euo pipefail

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> ~/.cache/wayfire-autostart.log
}

# Wait for Wayfire to start
log "Waiting for Wayfire to start..."
sleep 3

# Check if Wayfire is running
if ! pgrep -x "wayfire" > /dev/null; then
    log "ERROR: Wayfire is not running"
    exit 1
fi

log "Wayfire autostart completed successfully"

# Start additional services if needed
# Add your custom autostart commands here
EOF
    
    if chmod +x "$autostart_script"; then
        log_success "Autostart script created and made executable"
    else
        log_error "Failed to create autostart script"
    fi
}

# Install additional fonts if needed
install_fonts() {
    log_info "Installing additional fonts..."
    
    if ! fc-list | grep -q "FiraCode Nerd Font"; then
        log_warning "FiraCode Nerd Font not found. Installing..."
        if ! sudo pacman -S --noconfirm fira-code-nerd-font; then
            log_error "Failed to install FiraCode Nerd Font"
        fi
    fi
    
    # Refresh font cache
    if command -v fc-cache &> /dev/null; then
        if fc-cache -fv; then
            log_success "Font cache refreshed"
        else
            log_warning "Failed to refresh font cache"
        fi
    fi
}

# Set up GTK theme
setup_gtk_theme() {
    log_info "Setting up GTK theme..."
    
    if ! pacman -Q | grep -q "cachyos-nord"; then
        log_warning "CachyOS Nord theme not found. Installing..."
        if ! sudo pacman -S --noconfirm cachyos-nord; then
            log_warning "Failed to install CachyOS Nord theme"
        fi
    fi
}

# Configure display manager
configure_display_manager() {
    log_info "Configuring display manager..."
    
    if command -v systemctl &> /dev/null; then
        local dm_found=false
        
        for dm in gdm lightdm sddm; do
            if systemctl is-enabled "$dm" &> /dev/null; then
                log_info "$dm detected. Wayfire should be available in session selection."
                dm_found=true
                break
            fi
        done
        
        if [[ "$dm_found" == false ]]; then
            log_warning "No display manager detected. You may need to start Wayfire manually."
        fi
    fi
}

# Create comprehensive test script
create_test_script() {
    log_info "Creating comprehensive test script..."
    
    cat > "$HOME/test-wayfire-enhanced.sh" << 'EOF'
#!/bin/bash

# Enhanced Wayfire Configuration Test Script
# Tests all components with detailed error reporting

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo "=========================================="
echo "🔍 Enhanced Wayfire Configuration Test"
echo "=========================================="
echo ""

# Test 1: Version Compatibility
log_info "1. Testing version compatibility..."
if command -v wayfire &> /dev/null; then
    wayfire_version=$(wayfire --version 2>/dev/null | head -1 || echo "unknown")
    log_info "Wayfire version: $wayfire_version"
    
    if [[ "$wayfire_version" == *"0.8"* ]]; then
        log_warning "⚠️  CachyOS Wayfire 0.8.x detected - compatibility issues possible"
    else
        log_success "✅ Wayfire version looks good"
    fi
else
    log_error "❌ Wayfire not found"
fi

# Test 2: wlroots compatibility
log_info "2. Testing wlroots compatibility..."
if command -v pkg-config &> /dev/null; then
    wlroots_version=$(pkg-config --modversion wlroots 2>/dev/null || echo "unknown")
    log_info "wlroots version: $wlroots_version"
    
    if [[ "$wlroots_version" == *"0.18"* ]]; then
        log_warning "⚠️  wlroots 0.18 detected - may have compatibility issues"
    else
        log_success "✅ wlroots version compatible"
    fi
else
    log_warning "⚠️  pkg-config not found - cannot check wlroots"
fi

# Test 3: Core applications
log_info "3. Testing core applications..."
apps=("wezterm" "waybar" "wofi" "nvim" "thunar")
for app in "${apps[@]}"; do
    if command -v "$app" &> /dev/null; then
        log_success "✅ $app found"
    else
        log_error "❌ $app not found"
    fi
done

# Test 4: Configuration files
log_info "4. Testing configuration files..."
configs=("wayfire.ini" "waybar/config" "wezterm/wezterm.lua" "wf-shell.ini")
for config in "${configs[@]}"; do
    if [[ -f "$HOME/.config/$config" ]]; then
        log_success "✅ $config exists"
    else
        log_error "❌ $config missing"
    fi
done

# Test 5: Waybar configuration
log_info "5. Testing Waybar configuration..."
if command -v waybar &> /dev/null; then
    if waybar --check-config &> /dev/null; then
        log_success "✅ Waybar configuration valid"
    else
        log_error "❌ Waybar configuration invalid"
    fi
else
    log_error "❌ Waybar not found"
fi

# Test 6: Font availability
log_info "6. Testing font availability..."
if fc-list | grep -q "FiraCode Nerd Font"; then
    log_success "✅ FiraCode Nerd Font found"
else
    log_error "❌ FiraCode Nerd Font missing"
fi

# Test 7: Waybar modules
log_info "7. Testing Waybar modules..."
modules=("storage.sh" "weather.sh" "spotify.sh" "mediaplayer.py")
for module in "${modules[@]}"; do
    if [[ -f "$HOME/.config/waybar/modules/$module" ]] || [[ -f "$HOME/.config/waybar/$module" ]]; then
        if [[ -x "$HOME/.config/waybar/modules/$module" ]] || [[ -x "$HOME/.config/waybar/$module" ]]; then
            log_success "✅ $module exists and executable"
        else
            log_warning "⚠️  $module exists but not executable"
        fi
    else
        log_error "❌ $module missing"
    fi
done

# Test 8: Environment variables
log_info "8. Testing environment variables..."
if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    log_success "✅ WAYLAND_DISPLAY set: $WAYLAND_DISPLAY"
else
    log_warning "⚠️  WAYLAND_DISPLAY not set"
fi

if [[ -n "${XDG_CURRENT_DESKTOP:-}" ]]; then
    log_success "✅ XDG_CURRENT_DESKTOP set: $XDG_CURRENT_DESKTOP"
else
    log_warning "⚠️  XDG_CURRENT_DESKTOP not set"
fi

# Test 9: System resources
log_info "9. Testing system resources..."
if [[ -d "/sys/class/hwmon" ]]; then
    hwmon_count=$(find /sys/class/hwmon -name "hwmon*" | wc -l)
    log_info "Found $hwmon_count hwmon devices"
else
    log_warning "⚠️  No hwmon devices found"
fi

# Test 10: Network connectivity
log_info "10. Testing network connectivity..."
if ping -c1 wttr.in &> /dev/null; then
    log_success "✅ Network connectivity OK"
else
    log_warning "⚠️  Network connectivity issues"
fi

echo ""
echo "=========================================="
echo "🎯 Test Summary"
echo "=========================================="
echo "✅ All tests completed"
echo ""
echo "If you see any ❌ errors, please fix them before using Wayfire"
echo "If you see any ⚠️  warnings, consider addressing them for optimal experience"
echo ""
echo "For troubleshooting, check:"
echo "- ~/.cache/wayfire-autostart.log"
echo "- journalctl --user -f -u wayfire"
echo "- waybar -l debug"
echo ""
echo "Test completed!"
EOF

    chmod +x "$HOME/test-wayfire-enhanced.sh"
    log_success "Enhanced test script created: ~/test-wayfire-enhanced.sh"
}

# Main installation function
main() {
    echo ""
    echo "=========================================="
    echo "🚀 SOTA Wayfire Configuration Installer"
    echo "Enhanced v2.1 - CachyOS Optimized"
    echo "=========================================="
    echo ""
    
    # Run all checks and installations
    security_check
    check_arch_system
    check_version_compatibility
    check_dependencies
    create_backup
    install_packages
    copy_configurations
    make_executable
    create_directories
    setup_environment
    create_desktop_entry
    setup_autostart
    install_fonts
    setup_gtk_theme
    configure_display_manager
    create_test_script
    
    # Final instructions
    echo ""
    echo "=========================================="
    echo "🎉 SOTA Wayfire Configuration Installed!"
    echo "=========================================="
    echo ""
    echo "🚨 IMPORTANT: Version Compatibility Notice"
    echo "CachyOS is using Wayfire 0.8.0-5 while upstream is at 0.11"
    echo "This may cause compatibility issues with wlroots 0.18"
    echo ""
    echo "Next steps:"
    echo "1. Run: ~/test-wayfire-enhanced.sh"
    echo "2. Log out of your current session"
    echo "3. Select 'Wayfire' from your display manager"
    echo "4. Log in to experience your new setup!"
    echo ""
    echo "Key features available:"
    echo "• Super + Enter: Open WezTerm terminal"
    echo "• Super + D: Application launcher"
    echo "• Super + Tab: Workspace overview"
    echo "• Super + H/J/K/L: Vim-style navigation"
    echo "• Super + B: Toggle blur effects"
    echo "• Super + M: System monitor (btop)"
    echo "• Super + R: Quick launch"
    echo ""
    echo "WezTerm features:"
    echo "• Ctrl+Alt+h/j/k/l: Vim-style pane navigation"
    echo "• Ctrl+Alt+s/v: Split panes"
    echo "• Ctrl+Alt+z: Toggle pane zoom"
    echo "• Ctrl+Alt+t: New tab"
    echo "• Ctrl+Alt+F/G/O: Dynamic font/opacity cycling"
    echo ""
    echo "For troubleshooting, run: ~/test-wayfire-enhanced.sh"
    echo ""
    echo "Configuration files are in: ~/.config/"
    echo "Backup of old config: ~/.config/wayfire.backup.*"
    echo ""
    echo "⚠️  Emergency Recovery:"
    echo "• Safe Mode: wayfire --safe-mode"
    echo "• Reset Config: Backup and reset wayfire.ini"
    echo "• Alternative WM: Switch to another window manager"
    echo ""
    echo "Enjoy your SOTA Wayfire experience! 🚀"
    echo ""
    
    # Ask if user wants to test the configuration
    read -p "Would you like to test the configuration now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Running enhanced configuration test..."
        "$HOME/test-wayfire-enhanced.sh"
    fi
    
    log_success "Installation script completed successfully!"
}

# Run main function
main "$@" 