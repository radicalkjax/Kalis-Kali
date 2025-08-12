#!/bin/bash
# Replace Directory Menu with Applications Menu

echo "Replacing Directory Menu with Applications Menu"
echo "=============================================="

# Check if container is running
if ! docker ps | grep -q kali-workspace; then
    echo "Error: kali-workspace container is not running"
    echo "Start it with: docker-compose up -d kali"
    exit 1
fi

docker exec kali-workspace bash -c '
    # Kill panel
    pkill xfce4-panel
    sleep 2
    
    # Create proper panel configuration with Applications Menu
    mkdir -p /root/.config/xfce4/xfconf/xfce-perchannel-xml
    
    cat > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=6;x=640;y=400"/>
      <property name="length" type="uint" value="100"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="size" type="uint" value="30"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/>
        <value type="int" value="2"/>
        <value type="int" value="3"/>
        <value type="int" value="4"/>
        <value type="int" value="5"/>
        <value type="int" value="6"/>
      </property>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="applicationsmenu">
      <property name="button-icon" type="string" value="kali-menu"/>
      <property name="button-title" type="string" value="Applications"/>
      <property name="show-button-title" type="bool" value="false"/>
      <property name="show-generic-names" type="bool" value="false"/>
      <property name="show-menu-icons" type="bool" value="true"/>
      <property name="show-tooltips" type="bool" value="true"/>
      <property name="custom-menu" type="bool" value="false"/>
    </property>
    <property name="plugin-2" type="string" value="separator">
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-3" type="string" value="launcher">
      <property name="items" type="array">
        <value type="string" value="xfce4-terminal.desktop"/>
      </property>
    </property>
    <property name="plugin-4" type="string" value="tasklist">
      <property name="show-handle" type="bool" value="false"/>
    </property>
    <property name="plugin-5" type="string" value="systray">
      <property name="show-frame" type="bool" value="false"/>
      <property name="size-max" type="uint" value="22"/>
    </property>
    <property name="plugin-6" type="string" value="clock">
      <property name="digital-format" type="string" value="%I:%M %p"/>
    </property>
  </property>
</channel>
EOF
    
    # Clear cache
    rm -rf /root/.cache/sessions/xfce4-panel*
    rm -rf /root/.cache/menus/*
    
    # Ensure kali menu is linked
    if [ -f /etc/xdg/menus/kali-applications.menu ] && [ ! -f /etc/xdg/menus/xfce-applications.menu ]; then
        ln -sf /etc/xdg/menus/kali-applications.menu /etc/xdg/menus/xfce-applications.menu
    fi
    
    # Start panel
    DISPLAY=host.docker.internal:0 xfce4-panel --disable-wm-check &
'

echo ""
echo "Menu replaced! The blue folder should now show application categories."