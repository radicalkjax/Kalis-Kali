#!/bin/bash
# Start XFCE desktop environment properly with all components

echo "Starting Complete XFCE Desktop Environment"
echo "========================================="

# Check if container is running
if ! docker ps | grep -q kali-workspace; then
    echo "Error: kali-workspace container is not running"
    echo "Start it with: docker-compose up -d kali"
    exit 1
fi

# Check XQuartz
if ! pgrep -x "XQuartz" > /dev/null; then
    echo "Starting XQuartz..."
    open -a XQuartz
    sleep 3
fi

# Configure XQuartz
echo "Configuring XQuartz..."
defaults write org.xquartz.X11 nolisten_tcp -bool false
defaults write org.xquartz.X11 no_auth -bool false
defaults write org.xquartz.X11 enable_iglx -bool true

# Set xhost permissions
export DISPLAY=:0
xhost + > /dev/null 2>&1

# Start X11 bridge if needed
if ! pgrep -f "socat.*6000" > /dev/null; then
    echo "Starting X11 bridge..."
    nohup socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:"/tmp/.X11-unix/X0" > /tmp/socat-x11.log 2>&1 &
    sleep 1
fi

echo "Setting up desktop environment in container..."
docker exec kali-workspace bash -c '
    # Kill all existing XFCE processes
    echo "Cleaning up existing processes..."
    pkill -9 -f xfce4 2>/dev/null
    pkill -9 -f xfwm4 2>/dev/null
    pkill -9 -f xfdesktop 2>/dev/null
    sleep 2
    
    # Start D-Bus
    echo "Starting D-Bus..."
    service dbus start 2>/dev/null || true
    
    # Ensure required packages are installed
    echo "Checking required packages..."
    apt-get update >/dev/null 2>&1
    apt-get install -y \
        xfce4 \
        xfce4-session \
        xfwm4 \
        xfdesktop4 \
        xfce4-panel \
        xfce4-whiskermenu-plugin \
        dbus-x11 \
        kali-menu \
        >/dev/null 2>&1
    
    # Set up environment
    export DISPLAY=host.docker.internal:0
    export DBUS_SESSION_BUS_ADDRESS=$(dbus-launch --autolaunch=$(cat /var/lib/dbus/machine-id) --binary-syntax --close-stderr)
    export XDG_RUNTIME_DIR=/tmp/runtime-root
    mkdir -p $XDG_RUNTIME_DIR
    chmod 0700 $XDG_RUNTIME_DIR
    
    # Start window manager first
    echo "Starting window manager..."
    xfwm4 --compositor=off --sm-client-disable &
    sleep 2
    
    # Start desktop
    echo "Starting desktop..."
    xfdesktop --sm-client-disable &
    sleep 2
    
    # Start panel
    echo "Starting panel..."
    xfce4-panel --sm-client-disable &
    sleep 2
    
    # Start session components
    echo "Starting session components..."
    xfce4-session --sm-client-disable &
    
    echo "Desktop environment started!"
'

echo ""
echo "XFCE Desktop Environment is now running properly!"
echo "You should see:"
echo "- Window decorations on all windows"
echo "- Desktop with wallpaper"
echo "- Panel with working Applications Menu"
echo "- No error messages"
echo ""
echo "The Applications Menu should show all Kali tools in categories."