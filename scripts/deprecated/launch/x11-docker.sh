#!/bin/bash
# Complete X11 forwarding setup for Docker on macOS

echo "Complete X11 forwarding setup for Docker containers on macOS"
echo "==========================================================="

# Kill any existing socat processes
echo "Cleaning up existing socat processes..."
pkill -f "socat.*6000"

# Ensure XQuartz is installed
if ! command -v xquartz &> /dev/null; then
    echo "XQuartz not found. Please install it first:"
    echo "  brew install --cask xquartz"
    exit 1
fi

# Start XQuartz if not running
if ! pgrep -x "XQuartz" > /dev/null; then
    echo "Starting XQuartz..."
    open -a XQuartz
    sleep 3
fi

# Configure XQuartz
echo "Configuring XQuartz settings..."
defaults write org.xquartz.X11 nolisten_tcp -bool false
defaults write org.xquartz.X11 no_auth -bool false
defaults write org.xquartz.X11 enable_iglx -bool true

# Set DISPLAY
export DISPLAY=:0

# Set xhost permissions
echo "Setting xhost permissions..."
xhost + > /dev/null 2>&1

# Start socat bridge
echo "Starting socat TCP bridge..."
nohup socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:"/tmp/.X11-unix/X0" > /tmp/socat-x11.log 2>&1 &
SOCAT_PID=$!
echo "Socat started with PID: $SOCAT_PID"

# Wait a moment for socat to start
sleep 1

# Test the connection
echo ""
echo "Testing X11 connection..."
if docker exec kali-workspace sh -c "DISPLAY=host.docker.internal:0 xeyes" 2>&1 | grep -q "Error"; then
    echo "❌ X11 test failed. Checking troubleshooting steps..."
    echo ""
    echo "Troubleshooting:"
    echo "1. Make sure XQuartz is running"
    echo "2. Check XQuartz Preferences > Security > 'Allow connections from network clients'"
    echo "3. Restart XQuartz after changing settings"
else
    echo "✅ X11 connection working!"
    echo ""
    echo "To launch XFCE4 desktop:"
    echo "  docker exec -it kali-workspace sh -c 'DISPLAY=host.docker.internal:0 startxfce4'"
    echo ""
    echo "To run GUI applications:"
    echo "  docker exec kali-workspace sh -c 'DISPLAY=host.docker.internal:0 <app-name>'"
fi

echo ""
echo "Socat bridge PID: $SOCAT_PID"
echo "To stop the bridge: kill $SOCAT_PID"