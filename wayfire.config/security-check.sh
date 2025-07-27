#!/bin/bash

# 🔒 Security and Compatibility Check Script for SOTA Wayfire Configuration
# This script performs comprehensive security and compatibility checks

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_critical() { echo -e "${PURPLE}[CRITICAL]${NC} $1"; }

# Security check results
SECURITY_ISSUES=0
COMPATIBILITY_ISSUES=0
PERFORMANCE_ISSUES=0

# Check file permissions
check_file_permissions() {
    log_info "Checking file permissions..."
    
    local config_dir="$HOME/.config"
    local critical_files=(
        "wayfire.ini"
        "waybar/config"
        "wezterm/wezterm.lua"
        "wf-shell.ini"
    )
    
    for file in "${critical_files[@]}"; do
        if [[ -f "$config_dir/$file" ]]; then
            local perms=$(stat -c "%a" "$config_dir/$file")
            if [[ "$perms" != "644" ]] && [[ "$perms" != "600" ]]; then
                log_warning "Insecure permissions on $file: $perms (should be 644 or 600)"
                ((SECURITY_ISSUES++))
            else
                log_success "✅ Secure permissions on $file: $perms"
            fi
        fi
    done
}

# Check for dangerous commands in scripts
check_dangerous_commands() {
    log_info "Checking for dangerous commands in scripts..."
    
    local scripts=(
        "$HOME/.config/waybar/waybar.sh"
        "$HOME/.config/waybar/modules/storage.sh"
        "$HOME/.config/waybar/modules/weather.sh"
        "$HOME/.config/waybar/modules/spotify.sh"
    )
    
    local dangerous_patterns=(
        "rm -rf"
        "sudo"
        "chmod 777"
        "chown root"
        "su -"
        "eval"
        "exec"
    )
    
    for script in "${scripts[@]}"; do
        if [[ -f "$script" ]]; then
            for pattern in "${dangerous_patterns[@]}"; do
                if grep -q "$pattern" "$script"; then
                    log_warning "⚠️  Potentially dangerous command found in $(basename "$script"): $pattern"
                    ((SECURITY_ISSUES++))
                fi
            done
        fi
    done
}

# Check for hardcoded paths
check_hardcoded_paths() {
    log_info "Checking for hardcoded paths..."
    
    local config_dir="$HOME/.config"
    local config_files=(
        "wayfire.ini"
        "waybar/config"
        "wezterm/wezterm.lua"
        "wf-shell.ini"
    )
    
    for file in "${config_files[@]}"; do
        if [[ -f "$config_dir/$file" ]]; then
            if grep -q "/home/[^/]*/" "$config_dir/$file"; then
                log_warning "⚠️  Hardcoded home path found in $file"
                ((COMPATIBILITY_ISSUES++))
            fi
        fi
    done
}

# Check version compatibility
check_version_compatibility() {
    log_info "Checking version compatibility..."
    
    # Check Wayfire version
    if command -v wayfire &> /dev/null; then
        local wayfire_version=$(wayfire --version 2>/dev/null | head -1 || echo "unknown")
        log_info "Wayfire version: $wayfire_version"
        
        if [[ "$wayfire_version" == *"0.8"* ]]; then
            log_critical "🚨 CRITICAL: CachyOS Wayfire 0.8.x detected"
            log_critical "Upstream is at 0.11 - major compatibility issues possible"
            ((COMPATIBILITY_ISSUES++))
        fi
    fi
    
    # Check wlroots version
    if command -v pkg-config &> /dev/null; then
        local wlroots_version=$(pkg-config --modversion wlroots 2>/dev/null || echo "unknown")
        log_info "wlroots version: $wlroots_version"
        
        if [[ "$wlroots_version" == *"0.18"* ]]; then
            log_critical "🚨 CRITICAL: wlroots 0.18 detected"
            log_critical "May have compatibility issues with Wayfire 0.8"
            ((COMPATIBILITY_ISSUES++))
        fi
    fi
}

# Check for missing dependencies
check_missing_dependencies() {
    log_info "Checking for missing dependencies..."
    
    local critical_deps=(
        "wayfire"
        "waybar"
        "wezterm"
        "wofi"
        "curl"
        "playerctl"
    )
    
    for dep in "${critical_deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            log_error "❌ Missing critical dependency: $dep"
            ((COMPATIBILITY_ISSUES++))
        else
            log_success "✅ $dep found"
        fi
    done
}

# Check configuration syntax
check_config_syntax() {
    log_info "Checking configuration syntax..."
    
    # Check Waybar config
    if command -v waybar &> /dev/null; then
        if waybar --check-config &> /dev/null; then
            log_success "✅ Waybar configuration valid"
        else
            log_error "❌ Waybar configuration invalid"
            ((COMPATIBILITY_ISSUES++))
        fi
    fi
    
    # Check WezTerm config
    if command -v wezterm &> /dev/null; then
        if wezterm --config-file "$HOME/.config/wezterm/wezterm.lua" --config-file /dev/null &> /dev/null; then
            log_success "✅ WezTerm configuration valid"
        else
            log_error "❌ WezTerm configuration invalid"
            ((COMPATIBILITY_ISSUES++))
        fi
    fi
}

# Check for performance issues
check_performance_issues() {
    log_info "Checking for performance issues..."
    
    # Check WezTerm plugins
    if [[ -f "$HOME/.config/wezterm/wezterm.lua" ]]; then
        local plugin_count=$(grep -c "wezterm.plugin.require" "$HOME/.config/wezterm/wezterm.lua" || echo "0")
        if [[ "$plugin_count" -gt 3 ]]; then
            log_warning "⚠️  Many WezTerm plugins detected ($plugin_count) - may impact performance"
            ((PERFORMANCE_ISSUES++))
        fi
    fi
    
    # Check blur settings
    if [[ -f "$HOME/.config/wayfire.ini" ]]; then
        local blur_iterations=$(grep -E "bokeh_iterations|box_iterations|gaussian_iterations" "$HOME/.config/wayfire.ini" | awk -F'=' '{sum+=$2} END {print sum}')
        if [[ "$blur_iterations" -gt 15 ]]; then
            log_warning "⚠️  High blur iterations detected ($blur_iterations) - may impact performance"
            ((PERFORMANCE_ISSUES++))
        fi
    fi
}

# Check for security vulnerabilities
check_security_vulnerabilities() {
    log_info "Checking for security vulnerabilities..."
    
    # Check for world-writable files
    if find "$HOME/.config" -type f -perm -002 2>/dev/null | grep -q .; then
        log_critical "🚨 CRITICAL: World-writable files found in config directory"
        ((SECURITY_ISSUES++))
    fi
    
    # Check for suspicious environment variables
    local suspicious_vars=("WAYLAND_DISPLAY" "XDG_CURRENT_DESKTOP")
    for var in "${suspicious_vars[@]}"; do
        if [[ -n "${!var:-}" ]]; then
            log_info "Environment variable $var is set: ${!var}"
        fi
    done
    
    # Check for network connectivity in scripts
    local scripts=(
        "$HOME/.config/waybar/modules/weather.sh"
        "$HOME/.config/waybar/modules/spotify.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [[ -f "$script" ]]; then
            if grep -q "curl\|wget\|http" "$script"; then
                log_info "Network connectivity detected in $(basename "$script")"
            fi
        fi
    done
}

# Check for CachyOS-specific issues
check_cachyos_issues() {
    log_info "Checking for CachyOS-specific issues..."
    
    # Check if cachyos-hello is properly disabled
    if [[ -f "$HOME/.config/wf-shell.ini" ]]; then
        if grep -q "cachyos-hello.desktop" "$HOME/.config/wf-shell.ini" && ! grep -q "#.*cachyos-hello.desktop" "$HOME/.config/wf-shell.ini"; then
            log_warning "⚠️  cachyos-hello is enabled - may cause hanging issues"
            ((COMPATIBILITY_ISSUES++))
        else
            log_success "✅ cachyos-hello properly disabled"
        fi
    fi
    
    # Check for CachyOS-specific packages
    local cachyos_packages=("cachy-browser" "cachyos-nord")
    for pkg in "${cachyos_packages[@]}"; do
        if pacman -Q "$pkg" &> /dev/null; then
            log_success "✅ $pkg installed"
        else
            log_warning "⚠️  $pkg not installed"
        fi
    done
}

# Generate security report
generate_report() {
    echo ""
    echo "=========================================="
    echo "🔒 Security and Compatibility Report"
    echo "=========================================="
    echo ""
    
    if [[ $SECURITY_ISSUES -eq 0 ]] && [[ $COMPATIBILITY_ISSUES -eq 0 ]] && [[ $PERFORMANCE_ISSUES -eq 0 ]]; then
        log_success "🎉 All checks passed! Your configuration is secure and compatible."
    else
        echo "Issues found:"
        echo "- Security issues: $SECURITY_ISSUES"
        echo "- Compatibility issues: $COMPATIBILITY_ISSUES"
        echo "- Performance issues: $PERFORMANCE_ISSUES"
        echo ""
        
        if [[ $SECURITY_ISSUES -gt 0 ]]; then
            log_critical "🚨 Security issues detected - please address immediately"
        fi
        
        if [[ $COMPATIBILITY_ISSUES -gt 0 ]]; then
            log_warning "⚠️  Compatibility issues detected - may cause problems"
        fi
        
        if [[ $PERFORMANCE_ISSUES -gt 0 ]]; then
            log_warning "⚠️  Performance issues detected - consider optimization"
        fi
    fi
    
    echo ""
    echo "Recommendations:"
    echo "1. Keep your system updated"
    echo "2. Monitor Wayfire and wlroots compatibility"
    echo "3. Test configuration after major updates"
    echo "4. Report issues to CachyOS maintainers"
    echo ""
}

# Main function
main() {
    echo "=========================================="
    echo "🔒 SOTA Wayfire Security & Compatibility Check"
    echo "=========================================="
    echo ""
    
    check_file_permissions
    check_dangerous_commands
    check_hardcoded_paths
    check_version_compatibility
    check_missing_dependencies
    check_config_syntax
    check_performance_issues
    check_security_vulnerabilities
    check_cachyos_issues
    
    generate_report
}

# Run main function
main "$@" 