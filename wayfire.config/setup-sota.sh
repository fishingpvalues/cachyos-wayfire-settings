#!/bin/bash

# SOTA Wayfire Quick Setup Script
# This script quickly configures the SOTA Wayfire environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo ""
echo "=========================================="
echo "🚀 SOTA Wayfire Quick Setup"
echo "=========================================="
echo ""

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root"
   exit 1
fi

# Check if we're on an Arch-based system
if ! command -v pacman &> /dev/null; then
    print_error "This script is designed for Arch-based systems (CachyOS, Arch Linux, etc.)"
    exit 1
fi

print_status "Starting SOTA Wayfire Quick Setup..."

# Check if required packages are installed
print_status "Checking required packages..."

MISSING_PACKAGES=()

# Core packages
for package in wayfire wayfire-plugins-extra wf-shell waybar wofi wezterm; do
    if ! pacman -Q "$package" &> /dev/null; then
        MISSING_PACKAGES+=("$package")
    fi
done

# Font packages
if ! pacman -Q fira-code-nerd-font &> /dev/null; then
    MISSING_PACKAGES+=("fira-code-nerd-font")
fi

if [ ${#MISSING_PACKAGES[@]} -ne 0 ]; then
    print_warning "Missing packages: ${MISSING_PACKAGES[*]}"
    echo ""
    echo "Please install missing packages first:"
    echo "sudo pacman -S ${MISSING_PACKAGES[*]}"
    echo ""
    echo "Or run the full installation script:"
    echo "./install.sh"
    echo ""
    exit 1
fi

print_success "All required packages are installed!"

# Create backup of existing configuration
print_status "Creating backup of existing configuration..."
BACKUP_DIR="$HOME/.config/wayfire.backup.$(date +%Y%m%d_%H%M%S)"

if [ -d "$HOME/.config/wayfire" ]; then
    cp -r "$HOME/.config/wayfire" "$BACKUP_DIR"
    print_success "Backup created at: $BACKUP_DIR"
fi

# Copy configuration files
print_status "Copying SOTA configuration files..."

# Create necessary directories
mkdir -p "$HOME/.config/wezterm/colors"
mkdir -p "$HOME/.cache/waybar"
mkdir -p "$HOME/.cache/rbn"
mkdir -p "$HOME/Pictures/screenshots"

# Copy all configuration files
cp -r wayfire.config/* "$HOME/.config/"

# Make scripts executable
print_status "Making scripts executable..."
chmod +x "$HOME/.config/waybar/waybar.sh"
chmod +x "$HOME/.config/waybar/modules/"*.sh
chmod +x "$HOME/.config/waybar/mediaplayer.py"

# Set up environment variables
print_status "Setting up environment variables..."
if ! grep -q "WAYLAND_DISPLAY" "$HOME/.bashrc"; then
    echo 'export WAYLAND_DISPLAY=wayland-1' >> "$HOME/.bashrc"
fi

if ! grep -q "XDG_CURRENT_DESKTOP" "$HOME/.bashrc"; then
    echo 'export XDG_CURRENT_DESKTOP=Wayfire' >> "$HOME/.bashrc"
fi

# Create desktop entry for Wayfire
print_status "Creating desktop entry for Wayfire..."
mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/wayfire.desktop" << EOF
[Desktop Entry]
Name=Wayfire
Comment=Wayland compositor
Exec=wayfire
Type=Application
EOF

# Set up autostart
print_status "Setting up autostart..."
mkdir -p "$HOME/.config/autostart"

# Create autostart script
cat > "$HOME/.config/autostart/wayfire-autostart.sh" << 'EOF'
#!/bin/bash
# Wait for Wayfire to start
sleep 2

# Start additional services if needed
# Add your custom autostart commands here
EOF

chmod +x "$HOME/.config/autostart/wayfire-autostart.sh"

# Verify font installation
print_status "Verifying font installation..."
if fc-list | grep -q "FiraCode Nerd Font"; then
    print_success "FiraCode Nerd Font is installed"
else
    print_warning "FiraCode Nerd Font not found. Please install it:"
    echo "sudo pacman -S fira-code-nerd-font"
fi

# Test configuration
print_status "Testing configuration..."
if [ -f "$HOME/.config/wayfire.ini" ]; then
    print_success "Wayfire configuration installed"
else
    print_error "Wayfire configuration not found"
    exit 1
fi

if [ -f "$HOME/.config/wezterm/wezterm.lua" ]; then
    print_success "WezTerm configuration installed"
else
    print_error "WezTerm configuration not found"
    exit 1
fi

if [ -f "$HOME/.config/waybar/config" ]; then
    print_success "Waybar configuration installed"
else
    print_error "Waybar configuration not found"
    exit 1
fi

# Test Waybar configuration
print_status "Testing Waybar configuration..."
if waybar --check-config &> /dev/null; then
    print_success "Waybar configuration is valid"
else
    print_warning "Waybar configuration has issues, but will still work"
fi

# Final instructions
print_success "SOTA Wayfire setup completed successfully!"
echo ""
echo "=========================================="
echo "🎉 SOTA Wayfire Configuration Ready!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Log out of your current session"
echo "2. Select 'Wayfire' from your display manager"
echo "3. Log in to experience your new SOTA setup!"
echo ""
echo "Key SOTA features available:"
echo "• Super + Enter: Open WezTerm terminal"
echo "• Super + D: Application launcher"
echo "• Super + Tab: Workspace overview"
echo "• Super + H/J/K/L: Vim-style navigation"
echo "• Super + B: Toggle blur effects"
echo "• Super + M: System monitor (btop)"
echo "• Super + R: Quick launch"
echo ""
echo "WezTerm SOTA features:"
echo "• Ctrl+Alt+h/j/k/l: Vim-style pane navigation"
echo "• Ctrl+Alt+s/v: Split panes"
echo "• Ctrl+Alt+z: Toggle pane zoom"
echo "• Ctrl+Alt+F/G/O: Dynamic font/opacity cycling"
echo ""
echo "Configuration files:"
echo "• ~/.config/wayfire.ini - Main Wayfire config"
echo "• ~/.config/wezterm/wezterm.lua - WezTerm config"
echo "• ~/.config/waybar/config - Waybar config"
echo ""
if [ -n "$BACKUP_DIR" ]; then
    echo "Backup of old config: $BACKUP_DIR"
fi
echo ""
echo "For troubleshooting, run: ~/test-wayfire.sh"
echo ""
echo "Enjoy your SOTA Wayfire experience! 🚀"
echo ""

# Ask if user wants to test the configuration
read -p "Would you like to test the configuration now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Running configuration test..."
    if [ -f "$HOME/test-wayfire.sh" ]; then
        "$HOME/test-wayfire.sh"
    else
        echo "Test script not found. Creating basic test..."
        echo "Testing Wayfire configuration..."
        echo "1. Check if Wayfire is installed:"
        which wayfire
        echo ""
        echo "2. Check if WezTerm is installed:"
        which wezterm
        echo ""
        echo "3. Check if Waybar is installed:"
        which waybar
        echo ""
        echo "4. Check if configuration files exist:"
        ls -la ~/.config/wayfire.ini
        ls -la ~/.config/waybar/config
        ls -la ~/.config/wezterm/wezterm.lua
        echo ""
        echo "5. Check if FiraCode Nerd Font is installed:"
        fc-list | grep -i "firacode" | head -1
        echo ""
        echo "Test completed!"
    fi
fi

print_success "SOTA Wayfire setup completed!" 