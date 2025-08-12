#!/bin/bash
# Restore the original XFCE4 panel configuration

echo "Restoring original panel configuration..."

docker exec kali-workspace bash -c '
    echo "=== Restoring Original Panel Configuration ==="
    
    # Stop panel and config daemon
    echo "Stopping panel components..."
    xfce4-panel --quit 2>/dev/null || true
    pkill -9 xfce4-panel 2>/dev/null || true
    killall xfconfd 2>/dev/null || true
    sleep 2
    
    # Remove current configuration with sudo
    echo "Removing current configuration..."
    sudo rm -rf /root/.config/xfce4/panel
    sudo rm -rf /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
    rm -rf ~/.cache/sessions/xfce4-panel*
    
    # Create directories
    mkdir -p /root/.config/xfce4/xfconf/xfce-perchannel-xml
    
    # Create a vertical panel configuration
    cat > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=1;x=0;y=0"/>
      <property name="length" type="uint" value="100"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="size" type="uint" value="56"/>
      <property name="mode" type="uint" value="1"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/>
        <value type="int" value="2"/>
        <value type="int" value="3"/>
        <value type="int" value="4"/>
        <value type="int" value="5"/>
        <value type="int" value="6"/>
        <value type="int" value="7"/>
      </property>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="whiskermenu">
      <property name="button-icon" type="string" value="kali-menu"/>
      <property name="show-button-title" type="bool" value="false"/>
    </property>
    <property name="plugin-2" type="string" value="separator">
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-3" type="string" value="tasklist">
      <property name="show-labels" type="bool" value="true"/>
      <property name="show-handle" type="bool" value="false"/>
    </property>
    <property name="plugin-4" type="string" value="separator">
      <property name="expand" type="bool" value="true"/>
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-5" type="string" value="systray">
      <property name="show-frame" type="bool" value="false"/>
      <property name="size-max" type="uint" value="28"/>
    </property>
    <property name="plugin-6" type="string" value="clock">
      <property name="digital-format" type="string" value="%I:%M %p"/>
    </property>
    <property name="plugin-7" type="string" value="showdesktop"/>
  </property>
</channel>
EOF
    
    # Start panel with new configuration
    echo "Starting panel with restored configuration..."
    export DISPLAY=host.docker.internal:0
    export XDG_RUNTIME_DIR=/tmp/runtime-root
    mkdir -p $XDG_RUNTIME_DIR
    chmod 0700 $XDG_RUNTIME_DIR
    
    xfce4-panel --sm-client-disable &
    
    sleep 3
    
    echo "Panel restored!"
'

echo ""
echo "Panel UX has been restored!"
echo "You should now see a vertical panel on the left side with:"
echo "- Whisker menu (application launcher)"
echo "- Task list (window buttons)"
echo "- System tray"
echo "- Clock"
echo "- Show desktop button"