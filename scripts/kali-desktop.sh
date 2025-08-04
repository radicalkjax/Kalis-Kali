#!/bin/bash
# Launch full XFCE4 desktop from Kali container

echo "Starting Kali Linux XFCE4 Desktop Environment"
echo "============================================"

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

# Check if socat is running
if ! pgrep -f "socat.*6000" > /dev/null; then
    echo "Starting X11 bridge..."
    nohup socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:"/tmp/.X11-unix/X0" > /tmp/socat-x11.log 2>&1 &
    SOCAT_PID=$!
    echo "Socat bridge started (PID: $SOCAT_PID)"
    sleep 1
fi

# Install required packages for full desktop
echo "Ensuring all desktop components are installed..."
docker exec kali-workspace sh -c "
apt-get update > /dev/null 2>&1
apt-get install -y --no-install-recommends \
    xfce4-session \
    xfce4-panel \
    xfce4-terminal \
    xfdesktop4 \
    xfwm4 \
    xfce4-settings \
    xfce4-appfinder \
    dbus-x11 \
    x11-xserver-utils \
    kali-menu \
    xdg-utils \
    desktop-file-utils > /dev/null 2>&1
"

# Fix application menu entries
echo "Setting up Kali application menus..."
docker exec kali-workspace sh -c "
update-desktop-database /usr/share/applications 2>/dev/null || true
update-mime-database /usr/share/mime 2>/dev/null || true
gtk-update-icon-cache -f /usr/share/icons/hicolor 2>/dev/null || true
rm -rf /home/kali/.cache/menus/* 2>/dev/null || true
rm -rf /home/kali/.config/menus/* 2>/dev/null || true
mkdir -p /home/kali/.local/share/applications
mkdir -p /home/kali/.config/menus
chown -R kali:kali /home/kali/.cache /home/kali/.config /home/kali/.local 2>/dev/null || true
"

# Kill any existing desktop processes
echo "Cleaning up any existing desktop sessions..."
docker exec kali-workspace sh -c "
pkill -f xfce4-session 2>/dev/null || true
pkill -f xfwm4 2>/dev/null || true
pkill -f xfdesktop 2>/dev/null || true
pkill -f xfce4-panel 2>/dev/null || true
sleep 2
"

echo ""
echo "Launching XFCE4 Desktop Components..."
echo "===================================="
echo ""

# Start D-Bus
echo "Starting D-Bus service..."
docker exec kali-workspace sh -c "service dbus start 2>/dev/null || true"

# Set up proper environment
docker exec kali-workspace sh -c "
export DISPLAY=host.docker.internal:0
export DBUS_SESSION_BUS_ADDRESS=\$(dbus-launch --autolaunch=\$(cat /var/lib/dbus/machine-id) --binary-syntax --close-stderr)
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p \$XDG_RUNTIME_DIR
chmod 0700 \$XDG_RUNTIME_DIR
"

# Start window manager first
echo "Starting window manager..."
docker exec -d kali-workspace sh -c "DISPLAY=host.docker.internal:0 xfwm4 --compositor=off --sm-client-disable"
sleep 2

# Launch desktop components
echo "Starting desktop background..."
docker exec -d kali-workspace sh -c "DISPLAY=host.docker.internal:0 xfdesktop --sm-client-disable"

echo "Starting desktop panel..."
docker exec -d kali-workspace sh -c "DISPLAY=host.docker.internal:0 xfce4-panel --sm-client-disable"

echo "Starting terminal..."
docker exec -d kali-workspace sh -c "DISPLAY=host.docker.internal:0 xfce4-terminal"

echo ""
echo "XFCE4 Desktop components launched!"
echo "================================="
echo ""
echo "You should see:"
echo "- XFCE4 Panel (taskbar)"
echo "- Desktop with right-click menu"
echo "- Terminal window"
echo "- Application Finder"
echo ""
echo "Use Application Finder to launch any Kali tool"
echo ""
echo "To stop: Close all windows or press Ctrl+C here"

# Keep script running and monitor
while true; do
    if ! docker ps | grep -q kali-workspace; then
        echo "Container stopped"
        break
    fi
    sleep 5
done