#!/bin/bash

# Menu System Debug Utility
# Comprehensive diagnostics for menu/panel issues

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_msg() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_error() {
    echo -e "${RED}[!]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[*]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

echo "======================================"
echo "     Kali Menu System Diagnostics     "
echo "======================================"
echo ""

# Check if in container
if [ -f /.dockerenv ]; then
    print_msg "Running in Docker container"
else
    print_warning "Not running in Docker container"
fi

# System information
print_info "System Information:"
echo "  OS: $(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "  Kernel: $(uname -r)"
echo "  User: $(whoami)"
echo ""

# Check package installations
print_info "Checking required packages..."
PACKAGES=(
    "kali-menu"
    "kali-desktop-xfce"
    "xfce4"
    "xfce4-whiskermenu-plugin"
    "menu"
    "menu-xdg"
    "libgarcon-1-0"
    "libgarcon-common"
    "desktop-file-utils"
)

missing_packages=()
for pkg in "${PACKAGES[@]}"; do
    if dpkg -l | grep -q "^ii  $pkg"; then
        echo "  ✓ $pkg"
    else
        echo "  ✗ $pkg (NOT INSTALLED)"
        missing_packages+=("$pkg")
    fi
done
echo ""

if [ ${#missing_packages[@]} -gt 0 ]; then
    print_error "Missing packages detected!"
    print_info "Install with: apt-get install ${missing_packages[*]}"
    echo ""
fi

# Check menu files
print_info "Checking menu configuration files..."
FILES=(
    "/etc/xdg/menus/xfce-applications.menu"
    "/etc/xdg/menus/applications-merged/kali-applications.menu"
    "/usr/share/kali-menu/update-kali-menu"
    "/home/kali/.config/menus/xfce-applications.menu"
    "/home/kali/.config/xfce4/panel/whiskermenu-1.rc"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        size=$(stat -c%s "$file")
        echo "  ✓ $file (${size} bytes)"
    else
        echo "  ✗ $file (NOT FOUND)"
    fi
done
echo ""

# Check desktop files
print_info "Checking desktop application entries..."
app_dirs=(
    "/usr/share/applications"
    "/usr/local/share/applications"
    "/home/kali/.local/share/applications"
)

total_apps=0
kali_apps=0
for dir in "${app_dirs[@]}"; do
    if [ -d "$dir" ]; then
        count=$(find "$dir" -name "*.desktop" 2>/dev/null | wc -l)
        kali_count=$(find "$dir" -name "*.desktop" -exec grep -l "Categories=.*kali" {} \; 2>/dev/null | wc -l)
        echo "  $dir: $count files ($kali_count Kali-specific)"
        total_apps=$((total_apps + count))
        kali_apps=$((kali_apps + kali_count))
    fi
done
echo "  Total: $total_apps desktop files ($kali_apps Kali tools)"
echo ""

# Check Kali menu categories
print_info "Checking Kali menu categories..."
if [ -f "/etc/xdg/menus/applications-merged/kali-applications.menu" ]; then
    categories=$(grep "<Name>" /etc/xdg/menus/applications-merged/kali-applications.menu | \
                sed 's/.*<Name>//;s/<\/Name>//' | sort -u)
    echo "Found categories:"
    echo "$categories" | while read cat; do
        echo "  • $cat"
    done
else
    print_error "Kali menu file not found!"
fi
echo ""

# Check panel configuration
print_info "Checking XFCE panel configuration..."
panel_config="/home/kali/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"
if [ -f "$panel_config" ]; then
    # Check for whiskermenu plugin
    if grep -q "whiskermenu" "$panel_config"; then
        echo "  ✓ Whisker menu plugin configured"
    else
        echo "  ✗ Whisker menu plugin NOT configured"
    fi
    
    # Count panel plugins
    plugin_count=$(grep -c "plugin-" "$panel_config" || echo "0")
    echo "  Panel plugins configured: $plugin_count"
else
    echo "  ✗ Panel configuration not found"
fi
echo ""

# Check running processes
print_info "Checking XFCE processes..."
xfce_processes=(
    "xfce4-panel"
    "xfce4-session"
    "xfdesktop"
    "xfwm4"
    "thunar"
)

for proc in "${xfce_processes[@]}"; do
    if pgrep -x "$proc" > /dev/null; then
        echo "  ✓ $proc (running)"
    else
        echo "  ✗ $proc (not running)"
    fi
done
echo ""

# Check environment variables
print_info "Checking environment variables..."
env_vars=(
    "DISPLAY"
    "XDG_SESSION_TYPE"
    "XDG_CURRENT_DESKTOP"
    "XDG_CONFIG_HOME"
    "XDG_DATA_HOME"
    "XDG_MENU_PREFIX"
)

for var in "${env_vars[@]}"; do
    value="${!var}"
    if [ -n "$value" ]; then
        echo "  $var=$value"
    else
        echo "  $var=(not set)"
    fi
done
echo ""

# Generate diagnostic report
print_info "Generating diagnostic commands..."
echo "Run these commands to fix common issues:"
echo ""
echo "# 1. Reinstall kali-menu (if missing):"
echo "apt-get update && apt-get install -y kali-menu kali-desktop-xfce"
echo ""
echo "# 2. Update menu database:"
echo "update-desktop-database /usr/share/applications"
echo "/usr/share/kali-menu/update-kali-menu"
echo ""
echo "# 3. Reset panel configuration:"
echo "xfce4-panel --quit"
echo "rm -rf ~/.config/xfce4/panel"
echo "xfce4-panel &"
echo ""
echo "# 4. Clear menu cache:"
echo "rm -rf ~/.cache/menus ~/.cache/xfce4"
echo ""
echo "# 5. Configure menu properly:"
echo "./scripts/desktop/configure-menu.sh"
echo ""

# Summary
echo "======================================"
print_info "Diagnostic Summary"
echo "======================================"

if [ ${#missing_packages[@]} -eq 0 ]; then
    print_msg "All required packages installed"
else
    print_error "${#missing_packages[@]} packages missing"
fi

if [ -f "/etc/xdg/menus/applications-merged/kali-applications.menu" ]; then
    print_msg "Kali menu structure present"
else
    print_error "Kali menu structure missing"
fi

if [ $kali_apps -gt 0 ]; then
    print_msg "$kali_apps Kali tools found"
else
    print_warning "No Kali tools found in menus"
fi

echo ""
print_info "For automatic fix, run:"
echo "  ./scripts/desktop/configure-menu.sh"