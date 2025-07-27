#!/bin/bash

# ⚡ Quick SOTA Wayfire Configuration Installer
# This script only copies configuration files (no package installation)

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

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$CONFIG_DIR/wayfire.backup.$(date +%Y%m%d_%H%M%S)"

echo ""
echo "=========================================="
echo "⚡ Quick SOTA Wayfire Configuration Installer"
echo "=========================================="
echo ""

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    log_error "This script should not be run as root"
    exit 1
fi

# Check if we're on an Arch-based system
if ! command -v pacman &> /dev/null; then
    log_error "This script is designed for Arch-based systems"
    exit 1
fi

# Check if required packages are installed
log_info "Checking if required packages are installed..."

MISSING_PACKAGES=()
REQUIRED_PACKAGES=("wayfire" "wayfire-plugins-extra" "wf-shell" "waybar" "wofi" "wezterm")

for package in "${REQUIRED_PACKAGES[@]}"; do
    if ! pacman -Q "$package" &> /dev/null; then
        MISSING_PACKAGES+=("$package")
    fi
done

if [[ ${#MISSING_PACKAGES[@]} -gt 0 ]]; then
    log_error "Missing required packages: ${MISSING_PACKAGES[*]}"
    echo ""
    echo "Please install missing packages first:"
    echo "sudo pacman -S ${MISSING_PACKAGES[*]}"
    echo ""
    echo "Or run the full installation script:"
    echo "./install.sh"
    echo ""
    exit 1
fi

log_success "All required packages are installed!"

# Create backup
log_info "Creating backup of existing configuration..."
if [[ -d "$CONFIG_DIR/wayfire" ]]; then
    if cp -r "$CONFIG_DIR/wayfire" "$BACKUP_DIR"; then
        log_success "Backup created: $BACKUP_DIR"
    else
        log_error "Failed to create backup"
        exit 1
    fi
else
    log_info "No existing Wayfire configuration found"
fi

# Create necessary directories
log_info "Creating necessary directories..."
mkdir -p "$CONFIG_DIR/wezterm/colors"
mkdir -p "$HOME/.cache/waybar"
mkdir -p "$HOME/.cache/rbn"
mkdir -p "$HOME/Pictures/screenshots"

# Copy configuration files
log_info "Copying configuration files..."
if ! cp -r "$SCRIPT_DIR"/* "$CONFIG_DIR/"; then
    log_error "Failed to copy configuration files"
    exit 1
fi

# Make scripts executable
log_info "Making scripts executable..."
chmod +x "$CONFIG_DIR/waybar/waybar.sh"
chmod +x "$CONFIG_DIR/waybar/modules/"*.sh
chmod +x "$CONFIG_DIR/waybar/mediaplayer.py"
chmod +x "$CONFIG_DIR/security-check.sh"

# Set up environment variables
log_info "Setting up environment variables..."
if ! grep -q "WAYLAND_DISPLAY" "$HOME/.bashrc"; then
    echo 'export WAYLAND_DISPLAY=wayland-1' >> "$HOME/.bashrc"
fi

if ! grep -q "XDG_CURRENT_DESKTOP" "$HOME/.bashrc"; then
    echo 'export XDG_CURRENT_DESKTOP=Wayfire' >> "$HOME/.bashrc"
fi

# Create desktop entry
log_info "Creating desktop entry for Wayfire..."
mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/wayfire.desktop" << 'EOF'
[Desktop Entry]
Name=Wayfire
Comment=Wayland compositor
Exec=wayfire
Type=Application
Categories=System;Settings;
Keywords=wayland;compositor;window manager;
EOF

# Final instructions
echo ""
echo "=========================================="
echo "🎉 Quick Installation Completed!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Run: ~/.config/security-check.sh"
echo "2. Log out of your current session"
echo "3. Select 'Wayfire' from your display manager"
echo "4. Log in to experience your new setup!"
echo ""
echo "Configuration files are in: ~/.config/"
echo "Backup of old config: $BACKUP_DIR"
echo ""
echo "For troubleshooting, run: ~/.config/security-check.sh"
echo ""
echo "Enjoy your SOTA Wayfire experience! 🚀"
echo ""

# Ask if user wants to run security check
read -p "Would you like to run security check now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "Running security check..."
    "$CONFIG_DIR/security-check.sh"
fi

log_success "Quick installation completed!" 