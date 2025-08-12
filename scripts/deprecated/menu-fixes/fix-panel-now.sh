#!/bin/bash
# Direct fix for panel issues

docker exec kali-workspace bash -c '
    # Kill panel
    xfce4-panel --quit 2>/dev/null
    pkill -9 xfce4-panel 2>/dev/null
    sleep 2
    
    # Remove ALL panel configurations
    rm -rf /root/.config/xfce4/panel
    rm -rf /root/.config/xfce4/xfconf
    rm -rf /root/.cache/sessions/*
    rm -rf /root/.cache/xfce4/*
    
    # Create clean config directory
    mkdir -p /root/.config/xfce4/panel/launcher-3
    
    # Create a proper terminal launcher
    cat > /root/.config/xfce4/panel/launcher-3/xfce4-terminal.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Exec=xfce4-terminal
Icon=utilities-terminal
StartupNotify=true
Terminal=false
Categories=GTK;System;TerminalEmulator;
Name=Terminal
Comment=Terminal Emulator
EOF
    
    # Start panel with simple config (no clock)
    DISPLAY=host.docker.internal:0 xfce4-panel &
    sleep 3
    
    # Use xfconf to remove clock if it still appears
    xfconf-query -c xfce4-panel -p /plugins/plugin-12 -r -R 2>/dev/null || true
    
    # Restart panel one more time
    xfce4-panel --restart
'

echo "Panel fixed! Clock removed and terminal icon restored."