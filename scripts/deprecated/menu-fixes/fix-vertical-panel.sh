#!/bin/bash
# Fix XFCE4 panel to be vertical with proper Kali styling

echo "Fixing vertical panel configuration for Kali user..."

docker exec -u kali kali-workspace bash -c '
    echo "=== Fixing Vertical Panel Configuration ==="
    
    # 1. Kill current panel and config daemon
    echo "Step 1: Stopping panel components..."
    xfce4-panel --quit 2>/dev/null || true
    pkill -9 xfce4-panel 2>/dev/null || true
    killall xfconfd 2>/dev/null || true
    sleep 2
    
    # 2. Backup and remove current config
    echo "Step 2: Backing up and removing current config..."
    cp ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml.backup 2>/dev/null || true
    rm -rf ~/.config/xfce4/panel
    rm -f ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
    rm -rf ~/.cache/sessions/xfce4-panel*
    
    # 3. Create directories
    echo "Step 3: Creating config directories..."
    mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml
    mkdir -p ~/.config/xfce4/panel
    mkdir -p ~/.config/gtk-3.0
    
    # 4. Set GTK theme for proper icons
    echo "Step 4: Setting GTK theme..."
    cat > ~/.gtkrc-2.0 <<EOF
gtk-icon-theme-name = "Flat-Remix-Blue-Dark"
gtk-theme-name = "Kali-Dark"
gtk-fallback-icon-theme = "hicolor"
EOF
    
    cat > ~/.config/gtk-3.0/settings.ini <<EOF
[Settings]
gtk-icon-theme-name = Flat-Remix-Blue-Dark
gtk-theme-name = Kali-Dark
gtk-application-prefer-dark-theme = 1
gtk-fallback-icon-theme = hicolor
EOF
    
    # 5. Create vertical panel configuration
    echo "Step 5: Creating vertical panel configuration..."
    cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=1;x=0;y=0"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="size" type="uint" value="48"/>
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
        <value type="int" value="12"/>
      </property>
      <property name="mode" type="uint" value="1"/>
      <property name="autohide-behavior" type="uint" value="0"/>
      <property name="background-style" type="uint" value="1"/>
      <property name="background-alpha" type="uint" value="80"/>
      <property name="enter-opacity" type="uint" value="100"/>
      <property name="leave-opacity" type="uint" value="100"/>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="whiskermenu">
      <property name="button-icon" type="string" value="kali-menu"/>
      <property name="button-title" type="string" value=""/>
      <property name="show-button-title" type="bool" value="false"/>
      <property name="show-generic-names" type="bool" value="false"/>
      <property name="show-tooltip" type="bool" value="false"/>
    </property>
    <property name="plugin-2" type="string" value="separator">
      <property name="style" type="uint" value="1"/>
      <property name="expand" type="bool" value="false"/>
    </property>
    <property name="plugin-3" type="string" value="launcher">
      <property name="items" type="array">
        <value type="string" value="terminal.desktop"/>
      </property>
    </property>
    <property name="plugin-4" type="string" value="launcher">
      <property name="items" type="array">
        <value type="string" value="firefox.desktop"/>
      </property>
    </property>
    <property name="plugin-5" type="string" value="launcher">
      <property name="items" type="array">
        <value type="string" value="thunar.desktop"/>
      </property>
    </property>
    <property name="plugin-6" type="string" value="launcher">
      <property name="items" type="array">
        <value type="string" value="burpsuite.desktop"/>
      </property>
    </property>
    <property name="plugin-7" type="string" value="launcher">
      <property name="items" type="array">
        <value type="string" value="wireshark.desktop"/>
      </property>
    </property>
    <property name="plugin-8" type="string" value="separator">
      <property name="style" type="uint" value="1"/>
      <property name="expand" type="bool" value="false"/>
    </property>
    <property name="plugin-9" type="string" value="tasklist">
      <property name="show-labels" type="bool" value="false"/>
      <property name="show-handle" type="bool" value="false"/>
      <property name="flat-buttons" type="bool" value="true"/>
      <property name="show-wireframes" type="bool" value="false"/>
      <property name="grouping" type="uint" value="1"/>
    </property>
    <property name="plugin-10" type="string" value="separator">
      <property name="expand" type="bool" value="true"/>
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-11" type="string" value="systray">
      <property name="square-icons" type="bool" value="true"/>
      <property name="show-frame" type="bool" value="false"/>
      <property name="size-max" type="uint" value="22"/>
    </property>
    <property name="plugin-12" type="string" value="clock">
      <property name="digital-format" type="string" value="%R"/>
      <property name="mode" type="uint" value="2"/>
    </property>
  </property>
</channel>
EOF
    
    # 6. Create launcher desktop files
    echo "Step 6: Creating launcher files..."
    
    # Terminal launcher
    mkdir -p ~/.config/xfce4/panel/launcher-3
    cat > ~/.config/xfce4/panel/launcher-3/terminal.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Terminal
Comment=Terminal Emulator
Exec=xfce4-terminal
Icon=utilities-terminal
Terminal=false
Categories=System;TerminalEmulator;
EOF
    
    # Firefox launcher
    mkdir -p ~/.config/xfce4/panel/launcher-4
    cat > ~/.config/xfce4/panel/launcher-4/firefox.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Firefox ESR
Comment=Web Browser
Exec=firefox-esr %u
Icon=firefox-esr
Terminal=false
Categories=Network;WebBrowser;
EOF
    
    # File Manager launcher
    mkdir -p ~/.config/xfce4/panel/launcher-5
    cat > ~/.config/xfce4/panel/launcher-5/thunar.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Thunar
Comment=File Manager
Exec=thunar %F
Icon=system-file-manager
Terminal=false
Categories=System;FileTools;FileManager;
EOF
    
    # Burp Suite launcher
    mkdir -p ~/.config/xfce4/panel/launcher-6
    cat > ~/.config/xfce4/panel/launcher-6/burpsuite.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Burp Suite
Comment=Web Security Testing
Exec=burpsuite
Icon=burpsuite
Terminal=false
Categories=Network;Security;
EOF
    
    # Wireshark launcher
    mkdir -p ~/.config/xfce4/panel/launcher-7
    cat > ~/.config/xfce4/panel/launcher-7/wireshark.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Wireshark
Comment=Network Protocol Analyzer
Exec=wireshark
Icon=wireshark
Terminal=false
Categories=Network;Monitor;
EOF
    
    # 7. Ensure whiskermenu plugin exists
    echo "Step 7: Checking whiskermenu plugin..."
    if ! which xfce4-whiskermenu-plugin >/dev/null 2>&1; then
        echo "Whiskermenu not found, using applicationsmenu instead..."
        sed -i "s/whiskermenu/applicationsmenu/g" ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
    fi
    
    # 8. Update icon cache
    echo "Step 8: Updating icon cache..."
    gtk-update-icon-cache -f /usr/share/icons/Flat-Remix-Blue-Dark 2>/dev/null || true
    gtk-update-icon-cache -f /usr/share/icons/hicolor 2>/dev/null || true
    
    # 9. Start panel
    echo "Step 9: Starting panel..."
    export DISPLAY=host.docker.internal:0
    export XDG_RUNTIME_DIR=/tmp/runtime-$USER
    mkdir -p $XDG_RUNTIME_DIR
    chmod 0700 $XDG_RUNTIME_DIR
    
    # Start xfconfd first
    xfconfd --daemon --replace &
    sleep 1
    
    # Start panel
    xfce4-panel --disable-wm-check &
    
    sleep 3
    
    echo "=== Vertical Panel Fix Complete ==="
    echo "Panel should now be:"
    echo "✓ Vertical on the left side"
    echo "✓ 48px wide"
    echo "✓ With Kali menu (or applications menu)"
    echo "✓ Quick launchers for common tools"
    echo "✓ Task list and system tray"
    echo "✓ Dark theme with transparency"
'

echo ""
echo "If the panel is still not correct, try:"
echo "1. Manually restart the panel: docker exec -u kali kali-workspace xfce4-panel -r"
echo "2. Check for errors: docker logs kali-workspace | tail -50"