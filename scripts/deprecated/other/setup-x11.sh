#!/bin/bash
# Setup X11 forwarding for Docker on macOS

echo "Setting up X11 forwarding for Docker containers..."

# Check if XQuartz is running
if ! pgrep -x "XQuartz" > /dev/null; then
    echo "Starting XQuartz..."
    open -a XQuartz
    sleep 2
fi

# Configure XQuartz settings
echo "Configuring XQuartz..."
defaults write org.xquartz.X11 nolisten_tcp -bool false
defaults write org.xquartz.X11 no_auth -bool false
defaults write org.xquartz.X11 enable_iglx -bool true

# Set DISPLAY variable
export DISPLAY=:0

# Allow connections
echo "Setting xhost permissions..."
xhost + > /dev/null 2>&1

# Get IP address for Docker
IP=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')
if [ -z "$IP" ]; then
    IP="host.docker.internal"
fi

echo "X11 forwarding setup complete!"
echo ""
echo "To test X11 in your container, run:"
echo "  docker exec kali-workspace sh -c \"DISPLAY=$IP:0 xeyes\""
echo ""
echo "For XFCE4, run:"
echo "  docker exec -it kali-workspace sh -c \"DISPLAY=$IP:0 startxfce4\""