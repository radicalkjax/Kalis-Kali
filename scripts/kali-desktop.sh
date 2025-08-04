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

echo "Configuring desktop panel..."
# Configure vertical panel layout
docker exec kali-workspace bash -c '
    # Kill any existing panel
    pkill xfce4-panel 2>/dev/null
    sleep 1
    
    # Create vertical panel configuration
    mkdir -p /root/.config/xfce4/xfconf/xfce-perchannel-xml
    
    cat > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=11;x=0;y=0"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="size" type="uint" value="56"/>
      <property name="length" type="uint" value="100"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/>
        <value type="int" value="2"/>
        <value type="int" value="3"/>
        <value type="int" value="4"/>
        <value type="int" value="5"/>
        <value type="int" value="6"/>
        <value type="int" value="7"/>
        <value type="int" value="8"/>
        <value type="int" value="9"/>
        <value type="int" value="10"/>
        <value type="int" value="11"/>
      </property>
      <property name="mode" type="uint" value="1"/>
      <property name="autohide-behavior" type="uint" value="0"/>
      <property name="background-style" type="uint" value="1"/>
      <property name="background-alpha" type="uint" value="90"/>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="whiskermenu">
      <property name="button-icon" type="string" value="kali-menu"/>
      <property name="show-button-title" type="bool" value="false"/>
    </property>
    <property name="plugin-2" type="string" value="separator">
      <property name="style" type="uint" value="1"/>
    </property>
    <property name="plugin-3" type="string" value="launcher">
      <property name="items" type="array">
        <value type="string" value="xfce4-terminal.desktop"/>
      </property>
    </property>
    <property name="plugin-4" type="string" value="launcher">
      <property name="items" type="array">
        <value type="string" value="firefox-esr.desktop"/>
      </property>
    </property>
    <property name="plugin-5" type="string" value="launcher">
      <property name="items" type="array">
        <value type="string" value="kali-burpsuite.desktop"/>
      </property>
    </property>
    <property name="plugin-6" type="string" value="launcher">
      <property name="items" type="array">
        <value type="string" value="kali-wireshark.desktop"/>
      </property>
    </property>
    <property name="plugin-7" type="string" value="launcher">
      <property name="items" type="array">
        <value type="string" value="thunar.desktop"/>
      </property>
    </property>
    <property name="plugin-8" type="string" value="separator">
      <property name="style" type="uint" value="1"/>
    </property>
    <property name="plugin-9" type="string" value="tasklist">
      <property name="show-labels" type="bool" value="false"/>
      <property name="show-handle" type="bool" value="false"/>
      <property name="flat-buttons" type="bool" value="true"/>
      <property name="sort-order" type="uint" value="4"/>
      <property name="grouping" type="uint" value="1"/>
    </property>
    <property name="plugin-10" type="string" value="separator">
      <property name="expand" type="bool" value="true"/>
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-11" type="string" value="systray">
      <property name="square-icons" type="bool" value="true"/>
      <property name="show-frame" type="bool" value="false"/>
    </property>
  </property>
</channel>
EOF
    
    # Configure window manager to respect panel space
    cat > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="margin_left" type="int" value="58"/>
    <property name="margin_right" type="int" value="0"/>
    <property name="margin_top" type="int" value="0"/>
    <property name="margin_bottom" type="int" value="0"/>
    <property name="snap_to_border" type="bool" value="true"/>
    <property name="snap_to_windows" type="bool" value="true"/>
    <property name="snap_width" type="int" value="10"/>
  </property>
</channel>
EOF
    
    # Clear cache
    rm -rf /root/.cache/sessions/xfce4-panel*
'

echo "Starting desktop panel..."
docker exec -d kali-workspace sh -c "DISPLAY=host.docker.internal:0 xfce4-panel --sm-client-disable"

echo "Starting terminal..."
docker exec -d kali-workspace sh -c "DISPLAY=host.docker.internal:0 xfce4-terminal"

echo ""
echo "XFCE4 Desktop launched with Vertical Panel!"
echo "=========================================="
echo ""
echo "Desktop features:"
echo "• Vertical panel on left side (56px wide)"
echo "• Whisker Menu at top (Kali dragon icon)"
echo "• Quick launchers: Terminal, Firefox, Burp Suite, Wireshark, Files"
echo "• Task list showing open windows (icons only)"
echo "• System tray at bottom"
echo "• Windows automatically tile beside panel"
echo ""
echo "💡 Tips:"
echo "• Click Kali dragon for all applications"
echo "• Use quick launchers for common tools"
echo "• Windows snap to panel edge"
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