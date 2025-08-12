#!/bin/bash

# Configure Panel Icons Script
# Ensures panel launcher icons use appropriate themed icons

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

print_msg "Configuring Panel Launcher Icons"
echo "================================="

# Check if running in container
if [ ! -f /.dockerenv ]; then
    print_warning "Not running in container, fixing host config files"
fi

# Function to get better icon for specific launcher
get_better_icon() {
    local basename="$1"
    local current_icon="$2"
    
    case "$basename" in
        yara.desktop)
            echo "security-high"
            ;;
        binwalk.desktop)
            echo "application-x-firmware"
            ;;
        volatility3.desktop)
            echo "utilities-system-monitor"
            ;;
        hexedit.desktop|strings.desktop|hexdump.desktop)
            echo "accessories-text-editor"
            ;;
        objdump.desktop)
            echo "application-x-object"
            ;;
        *)
            echo "$current_icon"
            ;;
    esac
}

# Fix icons in config directory (host)
CONFIG_DIR="${1:-/home/kali/.config}"
if [ -d "$CONFIG_DIR/xfce4/panel" ]; then
    PANEL_DIR="$CONFIG_DIR/xfce4/panel"
else
    PANEL_DIR="./config/xfce4/panel"
fi

print_info "Checking panel launchers in: $PANEL_DIR"

# Process each launcher directory
FIXED_COUNT=0
for launcher_dir in $PANEL_DIR/launcher-*/; do
    if [ -d "$launcher_dir" ]; then
        for desktop_file in "$launcher_dir"*.desktop; do
            if [ -f "$desktop_file" ]; then
                basename=$(basename "$desktop_file")
                current_icon=$(grep "^Icon=" "$desktop_file" | cut -d= -f2)
                
                # Check if icon needs configuration
                if [[ "$current_icon" == "applications-system" ]] || \
                   [[ "$current_icon" == "application-x-executable" ]] || \
                   [[ "$current_icon" == "" ]]; then
                    
                    new_icon=$(get_better_icon "$basename" "$current_icon")
                    
                    if [ "$new_icon" != "$current_icon" ]; then
                        print_msg "Configuring $basename: $current_icon → $new_icon"
                        # Use portable sed command
                        if [[ "$OSTYPE" == "darwin"* ]]; then
                            sed -i '' "s/^Icon=.*/Icon=$new_icon/" "$desktop_file"
                        else
                            sed -i "s/^Icon=.*/Icon=$new_icon/" "$desktop_file"
                        fi
                        FIXED_COUNT=$((FIXED_COUNT + 1))
                    fi
                fi
            fi
        done
    fi
done

# Special handling for YARA launchers
print_info "Special handling for YARA launchers..."
for yara_file in $PANEL_DIR/launcher-*/yara.desktop; do
    if [ -f "$yara_file" ]; then
        # Update to use security-high icon
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/^Icon=.*/Icon=security-high/" "$yara_file"
        else
            sed -i "s/^Icon=.*/Icon=security-high/" "$yara_file"
        fi
        print_msg "Updated YARA icon in: $(dirname $yara_file)"
    fi
done

# Create custom YARA icon if we have permission
if [ "$EUID" -eq 0 ] && [ -f /.dockerenv ]; then
    print_info "Creating custom YARA icon link..."
    
    # Find a good security icon
    SECURITY_ICON=$(find /usr/share/icons -name "security-high.png" -o -name "security-high.svg" 2>/dev/null | head -1)
    
    if [ -n "$SECURITY_ICON" ] && [ -f "$SECURITY_ICON" ]; then
        # Create symlink for yara icon
        ICON_DIR="/usr/share/icons/hicolor/48x48/apps"
        mkdir -p "$ICON_DIR"
        ln -sf "$SECURITY_ICON" "$ICON_DIR/yara.png" 2>/dev/null || true
        
        # Update icon cache
        gtk-update-icon-cache /usr/share/icons/hicolor 2>/dev/null || true
        
        print_msg "Created custom YARA icon"
    fi
fi

# Summary
echo ""
echo "======================================"
print_msg "Icon Configuration Summary"
echo "======================================"

if [ $FIXED_COUNT -gt 0 ]; then
    print_msg "Configured $FIXED_COUNT launcher icons"
    
    # If panel is running, suggest restart
    if pgrep -x "xfce4-panel" >/dev/null 2>&1; then
        echo ""
        print_info "To apply changes, restart the panel:"
        echo "  xfce4-panel -r"
    fi
else
    print_msg "All launcher icons look good!"
fi

# List current icons
echo ""
print_info "Current launcher icons:"
for launcher_dir in $PANEL_DIR/launcher-*/; do
    if [ -d "$launcher_dir" ]; then
        for desktop_file in "$launcher_dir"*.desktop; do
            if [ -f "$desktop_file" ]; then
                name=$(grep "^Name=" "$desktop_file" | cut -d= -f2)
                icon=$(grep "^Icon=" "$desktop_file" | cut -d= -f2)
                launcher=$(basename $(dirname "$desktop_file"))
                echo "  $launcher: $name → $icon"
            fi
        done
    fi
done