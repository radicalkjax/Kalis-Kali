#!/bin/bash

# Script to easily run GUI applications with X11 forwarding

if [ $# -eq 0 ]; then
    echo "Usage: $0 <application> [arguments]"
    echo ""
    echo "Examples:"
    echo "  $0 firefox"
    echo "  $0 burpsuite"
    echo "  $0 wireshark"
    echo "  $0 ghidra"
    echo "  $0 startxfce4  # Full desktop"
    exit 1
fi

# Check if XQuartz is running
if ! pgrep -x "XQuartz" > /dev/null; then
    echo "Starting XQuartz..."
    open -a XQuartz
    sleep 2
fi

# Ensure X11 access
xhost +localhost 2>/dev/null || true

# Determine which container to use
CONTAINER_NAME="kali-workspace"
if docker ps --format '{{.Names}}' | grep -q "kali-malware-isolated"; then
    echo "Detected malware analysis container"
    CONTAINER_NAME="kali-malware-isolated"
elif docker ps --format '{{.Names}}' | grep -q "kali-malware-static"; then
    echo "Detected secure malware container"
    CONTAINER_NAME="kali-malware-static"
fi

# Run the GUI application
echo "Starting $1 in $CONTAINER_NAME..."
docker exec -it -e DISPLAY=host.docker.internal:0 $CONTAINER_NAME "$@"