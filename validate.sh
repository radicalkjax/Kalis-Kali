#!/bin/bash

# Validation Script - Checks if everything is set up correctly

set -e

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_pass() {
    echo -e "${GREEN}✓${NC} $1"
}

print_fail() {
    echo -e "${RED}✗${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

echo "======================================"
echo "     Kali Container Validation        "
echo "======================================"
echo ""

ERRORS=0
WARNINGS=0

# Check Docker
echo "Checking Docker..."
if docker info &> /dev/null; then
    print_pass "Docker is running"
else
    print_fail "Docker is not running"
    ((ERRORS++))
fi

# Check container
echo ""
echo "Checking container..."
if docker ps --format '{{.Names}}' | grep -q "^kali-workspace$"; then
    print_pass "Container 'kali-workspace' is running"
    
    # Get container details
    STATUS=$(docker ps --filter "name=kali-workspace" --format "{{.Status}}")
    print_info "Status: $STATUS"
else
    if docker ps -a --format '{{.Names}}' | grep -q "^kali-workspace$"; then
        print_warn "Container exists but is not running"
        ((WARNINGS++))
        print_info "Start with: ./scripts/core/start.sh"
    else
        print_fail "Container does not exist"
        ((ERRORS++))
        print_info "Create with: ./scripts/core/start.sh"
    fi
fi

# Check XQuartz (macOS only)
echo ""
echo "Checking X11 server..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [ -d "/Applications/Utilities/XQuartz.app" ]; then
        print_pass "XQuartz is installed"
        
        if pgrep -x "XQuartz" > /dev/null; then
            print_pass "XQuartz is running"
        else
            print_warn "XQuartz is not running"
            ((WARNINGS++))
            print_info "Will start automatically when needed"
        fi
    else
        print_fail "XQuartz is not installed"
        ((ERRORS++))
        print_info "Install with: brew install --cask xquartz"
    fi
else
    print_info "Not on macOS, X11 configuration may vary"
fi

# Check scripts
echo ""
echo "Checking scripts..."
REQUIRED_SCRIPTS=(
    "start.sh"
    "launch.sh"
    "scripts/core/start.sh"
    "scripts/core/stop.sh"
    "scripts/desktop/launch-desktop.sh"
    "scripts/desktop/configure-menu.sh"
)

for script in "${REQUIRED_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            print_pass "$script exists and is executable"
        else
            print_warn "$script exists but is not executable"
            ((WARNINGS++))
            print_info "Fix with: chmod +x $script"
        fi
    else
        print_fail "$script is missing"
        ((ERRORS++))
    fi
done

# Check directories
echo ""
echo "Checking directories..."
REQUIRED_DIRS=(
    "scripts/core"
    "scripts/desktop"
    "scripts/tools"
    "scripts/malware"
    "scripts/utils"
    "workspace"
    "config"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        print_pass "$dir exists"
    else
        print_fail "$dir is missing"
        ((ERRORS++))
    fi
done

# Check if container has required packages (if running)
if docker ps --format '{{.Names}}' | grep -q "^kali-workspace$"; then
    echo ""
    echo "Checking container packages..."
    
    # Check kali-menu
    if docker exec kali-workspace dpkg -l 2>/dev/null | grep -q "^ii  kali-menu"; then
        print_pass "kali-menu is installed"
    else
        print_warn "kali-menu is not installed"
        ((WARNINGS++))
        print_info "Install with: docker exec kali-workspace apt-get install -y kali-menu"
    fi
    
    # Check XFCE
    if docker exec kali-workspace dpkg -l 2>/dev/null | grep -q "^ii  xfce4"; then
        print_pass "XFCE4 desktop is installed"
    else
        print_fail "XFCE4 desktop is not installed"
        ((ERRORS++))
    fi
    
    # Check Claude
    if docker exec kali-workspace which claude &>/dev/null; then
        print_pass "Claude CLI is installed"
    else
        print_warn "Claude CLI is not installed"
        ((WARNINGS++))
        print_info "Configure with: ./launch.sh → Configuration → Setup Claude"
    fi
fi

# Summary
echo ""
echo "======================================"
echo "           Validation Summary          "
echo "======================================"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo "Your Kali container is ready to use:"
    echo "  • Quick start: ./start.sh"
    echo "  • Interactive: ./launch.sh"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ Validation passed with $WARNINGS warning(s)${NC}"
    echo ""
    echo "The container will work but some features may be limited."
    echo "Review the warnings above for improvements."
    exit 0
else
    echo -e "${RED}✗ Validation failed with $ERRORS error(s) and $WARNINGS warning(s)${NC}"
    echo ""
    echo "Please fix the errors above before using the container."
    echo "Start with: ./scripts/core/start.sh"
    exit 1
fi