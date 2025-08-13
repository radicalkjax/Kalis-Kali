#!/bin/bash

# Disable Sleep Mode and Auto-logout Script
# Prevents XFCE from going to sleep, locking screen, or logging out automatically

set -e

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}[+]${NC} Disabling sleep mode and auto-logout..."

# Create XFCE config directory if it doesn't exist
mkdir -p /home/kali/.config/xfce4/xfconf/xfce-perchannel-xml

# Disable screensaver completely
echo -e "${GREEN}[+]${NC} Disabling screensaver..."
cat > /home/kali/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-screensaver.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-screensaver" version="1.0">
  <property name="saver" type="empty">
    <property name="mode" type="int" value="0"/>
    <property name="enabled" type="bool" value="false"/>
  </property>
  <property name="lock" type="empty">
    <property name="enabled" type="bool" value="false"/>
    <property name="saver-activation" type="empty">
      <property name="enabled" type="bool" value="false"/>
    </property>
  </property>
</channel>
EOF

# Disable power management sleep/suspend
echo -e "${GREEN}[+]${NC} Disabling power management..."
cat > /home/kali/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-power-manager" version="1.0">
  <property name="xfce4-power-manager" type="empty">
    <property name="power-button-action" type="uint" value="0"/>
    <property name="sleep-button-action" type="uint" value="0"/>
    <property name="hibernate-button-action" type="uint" value="0"/>
    <property name="show-tray-icon" type="bool" value="false"/>
    <property name="dpms-enabled" type="bool" value="false"/>
    <property name="dpms-on-ac-sleep" type="uint" value="0"/>
    <property name="dpms-on-ac-off" type="uint" value="0"/>
    <property name="blank-on-ac" type="int" value="0"/>
    <property name="dpms-on-battery-sleep" type="uint" value="0"/>
    <property name="dpms-on-battery-off" type="uint" value="0"/>
    <property name="blank-on-battery" type="int" value="0"/>
    <property name="inactivity-on-ac" type="uint" value="0"/>
    <property name="inactivity-on-battery" type="uint" value="0"/>
    <property name="inactivity-sleep-mode-on-ac" type="uint" value="1"/>
    <property name="inactivity-sleep-mode-on-battery" type="uint" value="1"/>
    <property name="lock-screen-suspend-hibernate" type="bool" value="false"/>
    <property name="logind-handle-lid-switch" type="bool" value="false"/>
    <property name="logind-handle-power-key" type="bool" value="false"/>
    <property name="logind-handle-sleep-key" type="bool" value="false"/>
  </property>
</channel>
EOF

# Disable session auto-logout
echo -e "${GREEN}[+]${NC} Disabling session auto-logout..."
cat > /home/kali/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-session" version="1.0">
  <property name="general" type="empty">
    <property name="FailsafeSessionName" type="string" value="Failsafe"/>
    <property name="AutoSave" type="bool" value="false"/>
    <property name="PromptOnLogout" type="bool" value="false"/>
    <property name="SaveOnExit" type="bool" value="false"/>
  </property>
  <property name="shutdown" type="empty">
    <property name="LockScreen" type="bool" value="false"/>
  </property>
</channel>
EOF

# Kill any running screensaver processes
echo -e "${GREEN}[+]${NC} Stopping screensaver processes..."
pkill xfce4-screensaver 2>/dev/null || true
pkill xscreensaver 2>/dev/null || true
pkill light-locker 2>/dev/null || true

# Disable xscreensaver if it exists
if [ -f /home/kali/.xscreensaver ]; then
    echo -e "${GREEN}[+]${NC} Disabling xscreensaver..."
    sed -i 's/^mode:.*/mode: off/' /home/kali/.xscreensaver 2>/dev/null || true
    sed -i 's/^timeout:.*/timeout: 0/' /home/kali/.xscreensaver 2>/dev/null || true
    sed -i 's/^lock:.*/lock: False/' /home/kali/.xscreensaver 2>/dev/null || true
fi

# Disable light-locker if it exists
if command -v light-locker &> /dev/null; then
    echo -e "${GREEN}[+]${NC} Disabling light-locker..."
    mkdir -p /home/kali/.config/autostart
    cat > /home/kali/.config/autostart/light-locker.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Screen Locker
Comment=Launch screen locker program
Hidden=true
EOF
fi

# Set DPMS (Display Power Management Signaling) to off
if [ -n "$DISPLAY" ]; then
    echo -e "${GREEN}[+]${NC} Disabling DPMS..."
    xset -dpms 2>/dev/null || true
    xset s off 2>/dev/null || true
    xset s noblank 2>/dev/null || true
fi

# Ensure proper ownership
chown -R kali:kali /home/kali/.config 2>/dev/null || true

# Apply settings using xfconf-query if available
if command -v xfconf-query &> /dev/null; then
    echo -e "${GREEN}[+]${NC} Applying settings via xfconf..."
    
    # Screensaver settings
    xfconf-query -c xfce4-screensaver -p /saver/enabled -s false 2>/dev/null || true
    xfconf-query -c xfce4-screensaver -p /lock/enabled -s false 2>/dev/null || true
    
    # Power manager settings
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-enabled -s false 2>/dev/null || true
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac -s 0 2>/dev/null || true
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-off -s 0 2>/dev/null || true
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-sleep -s 0 2>/dev/null || true
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/inactivity-on-ac -s 0 2>/dev/null || true
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/lock-screen-suspend-hibernate -s false 2>/dev/null || true
    
    # Session settings
    xfconf-query -c xfce4-session -p /shutdown/LockScreen -s false 2>/dev/null || true
fi

echo -e "${GREEN}[+]${NC} Sleep mode and auto-logout disabled!"
echo -e "${YELLOW}[*]${NC} Changes will take full effect on next desktop session"