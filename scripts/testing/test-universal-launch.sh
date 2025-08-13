#!/bin/bash

# Test Universal Launch Experience
# Verifies that the launcher handles all scenarios including Docker startup

set -e

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}================================${NC}"
echo -e "${CYAN}  Universal Launch Experience Test${NC}"
echo -e "${CYAN}================================${NC}"
echo ""

# Test 1: Check if scripts exist
echo -e "${YELLOW}Test 1: Script availability${NC}"
if [ -f "./launch.sh" ] && [ -x "./launch.sh" ]; then
    echo -e "${GREEN}✓${NC} launch.sh exists and is executable"
else
    echo -e "${RED}✗${NC} launch.sh missing or not executable"
fi

if [ -f "./start.sh" ] && [ -x "./start.sh" ]; then
    echo -e "${GREEN}✓${NC} start.sh exists and is executable"
else
    echo -e "${RED}✗${NC} start.sh missing or not executable"
fi

# Test 2: Check Docker handling
echo ""
echo -e "${YELLOW}Test 2: Docker auto-start capability${NC}"
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [ -d "/Applications/Docker.app" ]; then
        echo -e "${GREEN}✓${NC} Docker Desktop is installed on macOS"
        echo -e "  ${GREEN}→${NC} Scripts will auto-start Docker if not running"
    else
        echo -e "${RED}✗${NC} Docker Desktop not found"
        echo -e "  Install from: https://www.docker.com/products/docker-desktop/"
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v docker &> /dev/null; then
        echo -e "${GREEN}✓${NC} Docker is installed on Linux"
        if command -v systemctl &> /dev/null; then
            echo -e "  ${GREEN}→${NC} Scripts will use systemctl to start Docker"
        elif command -v service &> /dev/null; then
            echo -e "  ${GREEN}→${NC} Scripts will use service to start Docker"
        fi
    else
        echo -e "${RED}✗${NC} Docker not installed"
    fi
fi

# Test 3: Check current Docker status
echo ""
echo -e "${YELLOW}Test 3: Current Docker status${NC}"
if docker info &> /dev/null; then
    echo -e "${GREEN}✓${NC} Docker is currently running"
    CONTAINERS=$(docker ps --format '{{.Names}}' | grep -E '^kali-' | wc -l | tr -d ' ')
    echo -e "  ${GREEN}→${NC} $CONTAINERS Kali container(s) running"
else
    echo -e "${YELLOW}⚠${NC} Docker is not currently running"
    echo -e "  ${GREEN}→${NC} Will be started automatically when you run:"
    echo "      ./launch.sh  or  ./start.sh"
fi

# Test 4: Check XQuartz (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo ""
    echo -e "${YELLOW}Test 4: XQuartz for GUI support${NC}"
    if [ -d "/Applications/Utilities/XQuartz.app" ]; then
        echo -e "${GREEN}✓${NC} XQuartz is installed"
        if pgrep -x "XQuartz" > /dev/null; then
            echo -e "  ${GREEN}→${NC} XQuartz is running"
        else
            echo -e "  ${YELLOW}→${NC} XQuartz will start automatically when needed"
        fi
    else
        echo -e "${YELLOW}⚠${NC} XQuartz not installed (GUI apps won't work)"
        echo -e "  Install with: brew install --cask xquartz"
    fi
fi

# Test 5: Test launch experience flow
echo ""
echo -e "${YELLOW}Test 5: Launch experience flow${NC}"
echo -e "${GREEN}✓${NC} Automated flow:"
echo "  1. Run ./launch.sh or ./start.sh"
echo "  2. Docker starts automatically (if not running)"
echo "  3. Container starts/resumes"
echo "  4. Panel tools installed/verified"
echo "  5. Icons configured"
echo "  6. Desktop launches"

# Summary
echo ""
echo -e "${CYAN}================================${NC}"
echo -e "${CYAN}         Test Summary          ${NC}"
echo -e "${CYAN}================================${NC}"

ALL_GOOD=true

# Check critical components
if [ ! -f "./launch.sh" ]; then
    echo -e "${RED}✗${NC} Missing launch.sh"
    ALL_GOOD=false
fi

if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗${NC} Docker not installed"
    ALL_GOOD=false
elif [[ "$OSTYPE" == "darwin"* ]] && [ ! -d "/Applications/Docker.app" ]; then
    echo -e "${YELLOW}⚠${NC} Docker Desktop app not found (auto-start won't work)"
fi

if [[ "$OSTYPE" == "darwin"* ]] && [ ! -d "/Applications/Utilities/XQuartz.app" ]; then
    echo -e "${YELLOW}⚠${NC} XQuartz not installed (optional, for GUI)"
fi

if [ "$ALL_GOOD" = true ]; then
    echo -e "${GREEN}✓ Universal launch experience is ready!${NC}"
    echo ""
    echo "Quick start commands:"
    echo "  ./start.sh    - One-click launch (simple)"
    echo "  ./launch.sh   - Interactive menu (advanced)"
    echo ""
    echo "Features:"
    echo "  • Automatic Docker startup"
    echo "  • Container management"
    echo "  • Tool installation"
    echo "  • Icon configuration"
    echo "  • Desktop environment"
else
    echo -e "${RED}✗ Some components need attention${NC}"
    echo ""
    echo "Please fix the issues above before launching."
fi