#!/bin/bash

# Ensure Panel Tools Script
# Installs all tools referenced in the XFCE panel configuration

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

print_msg "Ensuring Panel Tools are Installed"
echo "==================================="

# List of tools required by panel launchers
# Based on the .desktop files in config/xfce4/panel/launcher-*/
PANEL_TOOLS=(
    # Reverse Engineering Tools
    "ghidra"           # launcher-4, launcher-23
    "rizin-cutter"     # launcher-5 (was "cutter", now "rizin-cutter")
    "edb-debugger"     # launcher-6
    "radare2"          # launcher-27
    
    # Binary Analysis
    "binwalk"          # launcher-10
    "hexedit"          # launcher-9
    
    # Network Analysis
    "wireshark"        # launcher-7
    
    # Memory Analysis
    "volatility3"      # launcher-8
    
    # Basic tools (usually installed)
    "binutils"         # for objdump (launcher-25), strings (launcher-24)
    "bsdextrautils"    # for hexdump (launcher-26)
    
    # YARA
    "yara"             # launcher-11, launcher-28
)

# Check and install each tool
print_info "Checking installed tools..."
MISSING_TOOLS=()
INSTALLED_TOOLS=()

for tool in "${PANEL_TOOLS[@]}"; do
    # Special handling for some tools
    case $tool in
        "volatility3")
            # Check if volatility3 is available via Python
            if python3 -c "import volatility3" 2>/dev/null || command -v vol3 >/dev/null 2>&1 || command -v volatility3 >/dev/null 2>&1; then
                INSTALLED_TOOLS+=("$tool")
            else
                MISSING_TOOLS+=("$tool")
            fi
            ;;
        "binutils")
            # Check for objdump and strings
            if command -v objdump >/dev/null 2>&1 && command -v strings >/dev/null 2>&1; then
                INSTALLED_TOOLS+=("$tool")
            else
                MISSING_TOOLS+=("$tool")
            fi
            ;;
        "bsdextrautils")
            # Check for hexdump
            if command -v hexdump >/dev/null 2>&1; then
                INSTALLED_TOOLS+=("$tool")
            else
                MISSING_TOOLS+=("$tool")
            fi
            ;;
        "wireshark")
            # Check if wireshark GUI is available (not just wireshark-common)
            if command -v wireshark >/dev/null 2>&1; then
                INSTALLED_TOOLS+=("$tool")
            else
                MISSING_TOOLS+=("$tool")
            fi
            ;;
        "rizin-cutter")
            # Check for both rizin-cutter and cutter commands
            if command -v cutter >/dev/null 2>&1 || command -v rizin-cutter >/dev/null 2>&1; then
                INSTALLED_TOOLS+=("$tool")
            else
                MISSING_TOOLS+=("$tool")
            fi
            ;;
        *)
            # Standard check
            if command -v "$tool" >/dev/null 2>&1 || dpkg -l 2>/dev/null | grep -q "^ii  $tool"; then
                INSTALLED_TOOLS+=("$tool")
            else
                MISSING_TOOLS+=("$tool")
            fi
            ;;
    esac
done

# Report status
echo ""
print_info "Tool Status:"
for tool in "${INSTALLED_TOOLS[@]}"; do
    echo "  ✓ $tool"
done

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    echo ""
    print_warning "Missing tools:"
    for tool in "${MISSING_TOOLS[@]}"; do
        echo "  ✗ $tool"
    done
    
    echo ""
    print_msg "Installing missing tools..."
    
    # Check if we have root privileges
    if [ "$EUID" -ne 0 ]; then
        print_error "This script must be run as root for package installation"
        print_info "Please run as: docker exec kali-workspace bash -c '/home/kali/scripts/utils/ensure-panel-tools.sh'"
        exit 1
    fi
    
    # Update package lists
    apt-get update >/dev/null 2>&1
    
    # Install missing tools
    for tool in "${MISSING_TOOLS[@]}"; do
        echo -n "Installing $tool... "
        
        # Special handling for some packages
        case $tool in
            "volatility3")
                # Install via pip if not available as package
                if ! apt-get install -y volatility3 >/dev/null 2>&1; then
                    pip3 install --break-system-packages volatility3 >/dev/null 2>&1 && echo "done (via pip)" || echo "failed"
                else
                    echo "done"
                fi
                ;;
            "rizin-cutter")
                # Install rizin-cutter and create cutter symlink
                if apt-get install -y rizin-cutter >/dev/null 2>&1; then
                    # Create symlink for backward compatibility if needed
                    if [ ! -f /usr/bin/cutter ] && [ -f /usr/bin/rizin-cutter ]; then
                        ln -s /usr/bin/rizin-cutter /usr/bin/cutter 2>/dev/null || true
                    fi
                    echo "done"
                else
                    echo "failed"
                    print_warning "  Failed to install rizin-cutter - panel launcher may not work"
                fi
                ;;
            "wireshark")
                # Install full wireshark GUI package (not just wireshark-common)
                if apt-get install -y wireshark >/dev/null 2>&1; then
                    echo "done"
                else
                    echo "failed"
                    print_warning "  Failed to install wireshark - panel launcher may not work"
                fi
                ;;
            *)
                # Standard installation
                if apt-get install -y "$tool" >/dev/null 2>&1; then
                    echo "done"
                else
                    echo "failed"
                    print_warning "  Failed to install $tool - panel launcher may not work"
                fi
                ;;
        esac
    done
else
    print_msg "All panel tools are already installed!"
fi

# Verify critical tools
echo ""
print_info "Verifying critical panel tools..."
CRITICAL_TOOLS=("ghidra" "cutter" "wireshark" "radare2")
ALL_GOOD=true

for tool in "${CRITICAL_TOOLS[@]}"; do
    # Special verification for some tools
    case $tool in
        "cutter")
            # Check for either cutter or rizin-cutter
            if command -v cutter >/dev/null 2>&1 || command -v rizin-cutter >/dev/null 2>&1; then
                echo "  ✓ $tool is available"
            else
                echo "  ✗ $tool is NOT available"
                ALL_GOOD=false
            fi
            ;;
        *)
            if command -v "$tool" >/dev/null 2>&1; then
                echo "  ✓ $tool is available"
            else
                echo "  ✗ $tool is NOT available"
                ALL_GOOD=false
            fi
            ;;
    esac
done

# Create proper desktop files in system location if missing
print_info "Ensuring desktop files exist..."
DESKTOP_DIR="/usr/share/applications"

# Create desktop file for Cutter if missing
if ! [ -f "$DESKTOP_DIR/cutter.desktop" ]; then
    cat > "$DESKTOP_DIR/cutter.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Cutter
Comment=Free and Open Source Reverse Engineering Platform powered by Rizin
Exec=cutter %F
Icon=cutter
Terminal=false
Categories=Development;Security;ReverseEngineering;
MimeType=application/x-executable;application/x-elf;application/x-dosexec;
EOF
    print_msg "Created cutter.desktop"
fi

# Create desktop file for EDB if missing
if ! [ -f "$DESKTOP_DIR/edb-debugger.desktop" ]; then
    cat > "$DESKTOP_DIR/edb-debugger.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=EDB Debugger
Comment=Cross Platform x86/x86-64 Debugger
Exec=edb %F
Icon=edb
Terminal=false
Categories=Development;Security;Debugger;
EOF
    print_msg "Created edb-debugger.desktop"
fi

# Update desktop database
update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true

echo ""
if [ "$ALL_GOOD" = true ]; then
    print_msg "Panel tools setup complete!"
    print_info "All panel launchers should now work correctly"
else
    print_warning "Some tools could not be installed"
    print_info "Panel launchers for missing tools will show errors when clicked"
fi

# Offer to restart panel if running
if pgrep -x "xfce4-panel" >/dev/null; then
    echo ""
    print_info "XFCE panel is running. You may need to restart it for changes to take effect:"
    echo "  xfce4-panel -r"
fi