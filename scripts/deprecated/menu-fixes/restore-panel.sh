#!/bin/bash
# Restore panel to working state

echo "Restoring panel..."

docker exec kali-workspace bash -c '
    # Kill broken panel
    pkill xfce4-panel
    sleep 2
    
    # Remove broken config
    rm -rf /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
    rm -rf /root/.config/xfce4/panel
    
    # Start panel with defaults
    DISPLAY=host.docker.internal:0 xfce4-panel --disable-wm-check &
    sleep 3
    
    echo "Panel restored with default configuration"
'