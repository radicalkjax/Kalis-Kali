#!/bin/bash

# Quick Start - Launches Kali desktop with all tools
# This is the simplest way to get started

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     Kali Linux Quick Start                ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
echo ""

# Check if Docker is running, start if not
if ! docker info &> /dev/null; then
    echo -e "${YELLOW}[*]${NC} Docker is not running"
    
    # macOS - start Docker Desktop
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "${GREEN}[+]${NC} Starting Docker Desktop..."
        open -a Docker
        
        # Wait for Docker to be ready
        echo -n -e "${YELLOW}[*]${NC} Waiting for Docker to start"
        COUNTER=0
        MAX_WAIT=60
        
        while ! docker info &> /dev/null; do
            if [ $COUNTER -ge $MAX_WAIT ]; then
                echo ""
                echo -e "${RED}[!]${NC} Docker failed to start after ${MAX_WAIT} seconds"
                echo "Please check Docker Desktop and try again"
                exit 1
            fi
            
            if [ $((COUNTER % 3)) -eq 0 ]; then
                echo -n "."
            fi
            
            sleep 1
            COUNTER=$((COUNTER + 1))
        done
        echo ""
        echo -e "${GREEN}[+]${NC} Docker is ready!"
        sleep 2
    else
        echo -e "${RED}[!]${NC} Please start Docker manually"
        exit 1
    fi
fi

# Check if scripts exist
if [ ! -f "./scripts/core/start.sh" ]; then
    echo -e "${RED}[!]${NC} Scripts not found. Are you in the correct directory?"
    echo "Current directory: $(pwd)"
    exit 1
fi

# Start container if not running
if ! docker ps --format '{{.Names}}' | grep -q "^kali-workspace$"; then
    echo -e "${YELLOW}[*]${NC} Starting container..."
    ./scripts/core/start.sh
    
    # Give container time to initialize
    echo -e "${YELLOW}[*]${NC} Waiting for container to be ready..."
    sleep 5
    
    # Verify container started
    if ! docker ps --format '{{.Names}}' | grep -q "^kali-workspace$"; then
        echo -e "${RED}[!]${NC} Failed to start container"
        echo "Check Docker logs: docker logs kali-workspace"
        exit 1
    fi
fi

# Launch desktop
echo -e "${GREEN}[+]${NC} Launching Kali desktop..."
./scripts/desktop/launch-desktop.sh

echo ""
echo -e "${GREEN}[+]${NC} Desktop launched!"
echo ""
echo "Quick commands:"
echo "  • Open terminal in desktop: Right-click → Open Terminal"
echo "  • Access tools: Click Kali menu (top-left)"
echo "  • Stop container: ./scripts/core/stop.sh"