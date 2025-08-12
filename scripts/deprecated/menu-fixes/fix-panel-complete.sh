#!/bin/bash
# Complete XFCE4 panel configuration fix based on deep research

echo "Applying comprehensive panel fix..."

docker exec kali-workspace bash -c '
    echo "=== XFCE4 Panel Configuration Fix ==="
    
    # 1. Complete cleanup - kill xfconfd daemon (critical!)
    echo "Step 1: Stopping all panel components and xfconfd..."
    xfce4-panel --quit 2>/dev/null || true
    pkill -9 xfce4-panel 2>/dev/null || true
    killall xfconfd 2>/dev/null || true  # Critical - kills config daemon
    sleep 2
    
    # 2. Remove ALL configurations and caches
    echo "Step 2: Removing all cached configurations..."
    rm -rf /root/.config/xfce4/panel
    rm -rf /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
    rm -rf /root/.cache/sessions/xfce4-panel*
    rm -rf /root/.cache/xfce4/panel*
    rm -rf /root/.cache/sessions/xfce4-session*
    
    # 3. Install icon themes to fix white gear issue
    echo "Step 3: Installing icon themes..."
    apt-get update >/dev/null 2>&1
    apt-get install -y --no-install-recommends \
        tango-icon-theme \
        gnome-icon-theme \
        hicolor-icon-theme \
        adwaita-icon-theme \
        gtk-update-icon-cache >/dev/null 2>&1
    
    # 4. Update icon cache
    echo "Step 4: Updating icon cache..."
    gtk-update-icon-cache --force /usr/share/icons/hicolor 2>/dev/null || true
    gtk-update-icon-cache --force /usr/share/icons/Tango 2>/dev/null || true
    gtk-update-icon-cache --force /usr/share/icons/Adwaita 2>/dev/null || true
    
    # 5. Set GTK theme configuration
    echo "Step 5: Setting GTK theme..."
    mkdir -p /root/.config/gtk-3.0
    cat > /root/.gtkrc-2.0 <<EOF
gtk-icon-theme-name = "Adwaita"
gtk-theme-name = "Adwaita-dark"
EOF
    
    cat > /root/.config/gtk-3.0/settings.ini <<EOF
[Settings]
gtk-icon-theme-name = Adwaita
gtk-theme-name = Adwaita-dark
gtk-application-prefer-dark-theme = 1
EOF
    
    # 6. Create configuration directories
    echo "Step 6: Creating configuration directories..."
    mkdir -p /root/.config/xfce4/xfconf/xfce-perchannel-xml
    mkdir -p /root/.config/xfce4/panel
    
    # 7. Create vertical panel configuration WITHOUT clock
    echo "Step 7: Creating panel configuration (no clock)..."
    cat > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=1;x=0;y=0"/>
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
        <value type="string" value="16857497301.desktop"/>
      </property>
    </property>
    <property name="plugin-4" type="string" value="launcher">
      <property name="items" type="array">
        <value type="string" value="16857497302.desktop"/>
      </property>
    </property>
    <property name="plugin-5" type="string" value="launcher">
      <property name="items" type="array">
        <value type="string" value="16857497303.desktop"/>
      </property>
    </property>
    <property name="plugin-6" type="string" value="launcher">
      <property name="items" type="array">
        <value type="string" value="16857497304.desktop"/>
      </property>
    </property>
    <property name="plugin-7" type="string" value="launcher">
      <property name="items" type="array">
        <value type="string" value="16857497305.desktop"/>
      </property>
    </property>
    <property name="plugin-8" type="string" value="separator">
      <property name="style" type="uint" value="1"/>
    </property>
    <property name="plugin-9" type="string" value="tasklist">
      <property name="show-labels" type="bool" value="false"/>
      <property name="show-handle" type="bool" value="false"/>
      <property name="flat-buttons" type="bool" value="true"/>
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
    
    # 8. Create launcher desktop files with correct icons
    echo "Step 8: Creating launcher files..."
    mkdir -p /root/.config/xfce4/panel/launcher-3
    mkdir -p /root/.config/xfce4/panel/launcher-4
    mkdir -p /root/.config/xfce4/panel/launcher-5
    mkdir -p /root/.config/xfce4/panel/launcher-6
    mkdir -p /root/.config/xfce4/panel/launcher-7
    
    # Terminal
    cat > /root/.config/xfce4/panel/launcher-3/16857497301.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Terminal
Comment=Terminal Emulator
Exec=xfce4-terminal
Icon=utilities-terminal
Terminal=false
StartupNotify=true
Categories=GTK;System;TerminalEmulator;
EOF
    
    # Firefox
    cat > /root/.config/xfce4/panel/launcher-4/16857497302.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Firefox
Comment=Web Browser
Exec=firefox-esr
Icon=firefox-esr
Terminal=false
StartupNotify=true
Categories=Network;WebBrowser;
EOF
    
    # Burp Suite
    cat > /root/.config/xfce4/panel/launcher-5/16857497303.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Burp Suite
Comment=Web Security Testing
Exec=burpsuite
Icon=burpsuite
Terminal=false
StartupNotify=true
Categories=Network;Security;
EOF
    
    # Wireshark
    cat > /root/.config/xfce4/panel/launcher-6/16857497304.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Wireshark
Comment=Network Protocol Analyzer
Exec=wireshark
Icon=wireshark
Terminal=false
StartupNotify=true
Categories=Network;Monitor;
EOF
    
    # File Manager
    cat > /root/.config/xfce4/panel/launcher-7/16857497305.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=File Manager
Comment=Browse the file system
Exec=thunar
Icon=system-file-manager
Terminal=false
StartupNotify=true
Categories=System;Utility;Core;GTK;FileTools;FileManager;
EOF
    
    # 9. Set proper environment variables
    echo "Step 9: Setting environment variables..."
    export DISPLAY=host.docker.internal:0
    export XDG_CONFIG_HOME=/root/.config
    export XDG_CACHE_HOME=/root/.cache
    export XDG_CONFIG_DIRS=/etc/xdg
    export GTK2_RC_FILES=/root/.gtkrc-2.0
    
    # 10. Start panel (xfconfd will start automatically)
    echo "Step 10: Starting panel with new configuration..."
    xfce4-panel --disable-wm-check &
    
    echo ""
    echo "=== Panel Fix Complete ==="
    echo "The panel should now show:"
    echo "✓ Vertical layout on left side"
    echo "✓ NO clock widget"
    echo "✓ Terminal with proper icon"
    echo "✓ All launchers with correct icons"
'

echo ""
echo "Panel configuration has been completely reset!"
echo "The clock should be gone and all icons should be correct."