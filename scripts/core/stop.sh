#!/bin/bash

# Unified Kali Container Stop Script

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Parse arguments
ALL=false
if [[ "$1" == "--all" ]]; then
    ALL=true
fi

print_msg "Stopping Kali containers..."

# Get list of Kali containers
CONTAINERS=$(docker ps --format '{{.Names}}' | grep -E '^kali-' || true)

if [ -z "$CONTAINERS" ]; then
    print_warning "No running Kali containers found"
    exit 0
fi

# Stop containers
for container in $CONTAINERS; do
    print_msg "Stopping $container..."
    docker stop $container
done

# If --all flag, also remove stopped containers
if [ "$ALL" = true ]; then
    print_msg "Removing stopped Kali containers..."
    docker ps -a --format '{{.Names}}' | grep -E '^kali-' | xargs -r docker rm
fi

print_msg "All Kali containers stopped successfully!"

# Clean up X11 permissions if on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    xhost -localhost 2>/dev/null || true
fi