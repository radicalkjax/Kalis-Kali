#!/bin/bash
# Force reset panel to apply new configuration

echo "Resetting panel configuration..."

docker exec kali-workspace bash -c '
    # Kill panel
    pkill -9 xfce4-panel 2>/dev/null
    
    # Remove all panel configs and cache
    rm -rf /root/.config/xfce4/panel
    rm -rf /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
    rm -rf /root/.cache/sessions/xfce4-panel*
    rm -rf /root/.cache/xfce4/panel*
    
    echo "Panel configuration cleared"
'

echo "Restarting desktop with fresh configuration..."
echo "Please wait..."

# Run the desktop script which will create new panel config
./scripts/kali-desktop.sh