#!/bin/bash

# Test Panel Tools Script
# Verifies all panel launcher tools are accessible

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
echo "      Panel Tools Verification        "
echo "======================================"
echo ""

# Define panel tools and their expected commands
declare -A PANEL_TOOLS=(
    ["Terminal"]="xfce4-terminal"
    ["Ghidra"]="ghidra"
    ["Cutter"]="cutter"
    ["EDB Debugger"]="edb"
    ["Wireshark"]="wireshark"
    ["Volatility3"]="vol,vol3,volatility3"
    ["Hex Editor"]="hexedit"
    ["Binwalk"]="binwalk"
    ["YARA"]="yara"
    ["Radare2"]="radare2,r2"
    ["Strings"]="strings"
    ["Objdump"]="objdump"
    ["Hexdump"]="hexdump"
)

TOTAL=0
WORKING=0
BROKEN=0

print_info "Testing panel launcher tools..."
echo ""

for tool_name in "${!PANEL_TOOLS[@]}"; do
    commands="${PANEL_TOOLS[$tool_name]}"
    TOTAL=$((TOTAL + 1))
    
    # Split comma-separated commands
    IFS=',' read -ra CMD_ARRAY <<< "$commands"
    
    FOUND=false
    WORKING_CMD=""
    
    for cmd in "${CMD_ARRAY[@]}"; do
        # Trim whitespace
        cmd=$(echo "$cmd" | xargs)
        
        # Check if it's a complex command (contains space)
        if [[ "$cmd" == *" "* ]]; then
            # Execute complex command
            if eval "$cmd --version" >/dev/null 2>&1 || eval "$cmd --help" >/dev/null 2>&1; then
                FOUND=true
                WORKING_CMD="$cmd"
                break
            fi
        else
            # Simple command check
            if command -v "$cmd" >/dev/null 2>&1; then
                FOUND=true
                WORKING_CMD="$cmd"
                break
            fi
        fi
    done
    
    if [ "$FOUND" = true ]; then
        echo -e "  ${GREEN}✓${NC} $tool_name → $WORKING_CMD"
        WORKING=$((WORKING + 1))
    else
        echo -e "  ${RED}✗${NC} $tool_name → NOT FOUND (tried: $commands)"
        BROKEN=$((BROKEN + 1))
    fi
done

# Summary
echo ""
echo "======================================"
echo "           Test Summary               "
echo "======================================"

if [ $BROKEN -eq 0 ]; then
    print_msg "All $TOTAL panel tools are working!"
else
    print_warning "$WORKING/$TOTAL tools working, $BROKEN need attention"
    echo ""
    print_info "To fix missing tools, run:"
    echo "  docker exec --user root kali-workspace /home/kali/scripts/utils/ensure-panel-tools.sh"
fi

# Additional checks
echo ""
print_info "Additional verification:"

# Check if running in container
if [ -f /.dockerenv ]; then
    echo "  ✓ Running in Docker container"
else
    echo "  ⚠ Not running in container (run with: docker exec kali-workspace)"
fi

# Check if panel is running
if pgrep -x "xfce4-panel" >/dev/null; then
    echo "  ✓ XFCE panel is running"
else
    echo "  ⚠ XFCE panel is not running"
fi

# Check display
if [ -n "$DISPLAY" ]; then
    echo "  ✓ DISPLAY is set: $DISPLAY"
else
    echo "  ⚠ DISPLAY not set (GUI apps may not work)"
fi

echo ""
print_info "Panel restart command: xfce4-panel -r"