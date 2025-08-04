#!/bin/bash
# Fix panel to show Applications Menu instead of Directory Menu

echo "Fixing Panel Applications Menu"
echo "=============================="

# Check if container is running
if ! docker ps | grep -q kali-workspace; then
    echo "Error: kali-workspace container is not running"
    echo "Start it with: docker-compose up -d kali"
    exit 1
fi

docker exec kali-workspace bash -c '
    echo "Backing up current panel config..."
    mkdir -p /root/.config/xfce4/panel/backup
    cp -r /root/.config/xfce4/panel/* /root/.config/xfce4/panel/backup/ 2>/dev/null || true
    
    echo "Installing required menu packages..."
    apt-get update >/dev/null 2>&1
    apt-get install -y \
        kali-menu \
        xfce4-whiskermenu-plugin \
        garcon \
        xdg-utils \
        >/dev/null 2>&1
    
    echo "Stopping panel..."
    pkill xfce4-panel 2>/dev/null || true
    sleep 2
    
    echo "Creating new panel configuration with Applications Menu..."
    mkdir -p /root/.config/xfce4/panel/launcher-19
    
    # Create a launcher for applications menu
    cat > /root/.config/xfce4/panel/launcher-19/applications-menu.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Applications Menu
Comment=Show all applications
Icon=kali-menu
Exec=xfce4-popup-applicationsmenu
Categories=
EOF
    
    # Create basic panel config with applications menu
    cat > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=8;x=683;y=754"/>
      <property name="length" type="uint" value="100"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="size" type="uint" value="48"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/>
        <value type="int" value="3"/>
        <value type="int" value="15"/>
        <value type="int" value="4"/>
        <value type="int" value="5"/>
      </property>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="applicationsmenu">
      <property name="button-icon" type="string" value="kali-menu"/>
      <property name="show-button-title" type="bool" value="false"/>
      <property name="show-generic-names" type="bool" value="false"/>
      <property name="show-tooltips" type="bool" value="true"/>
      <property name="custom-menu" type="bool" value="false"/>
    </property>
    <property name="plugin-3" type="string" value="tasklist"/>
    <property name="plugin-15" type="string" value="separator">
      <property name="expand" type="bool" value="true"/>
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-4" type="string" value="systray"/>
    <property name="plugin-5" type="string" value="clock"/>
  </property>
</channel>
EOF
    
    echo "Ensuring Kali menu structure exists..."
    if [ ! -f /etc/xdg/menus/xfce-applications.menu ]; then
        ln -sf /etc/xdg/menus/kali-applications.menu /etc/xdg/menus/xfce-applications.menu 2>/dev/null || true
    fi
    
    echo "Clearing caches..."
    rm -rf /root/.cache/menus/*
    rm -rf /root/.cache/sessions/*
    
    echo "Starting panel with Applications Menu..."
    DISPLAY=host.docker.internal:0 xfce4-panel --disable-wm-check &
    sleep 3
'

echo ""
echo "Panel menu fixed!"
echo ""
echo "You should now see:"
echo "- A blue folder icon (Kali dragon logo)"
echo "- When clicked, it shows application categories like:"
echo "  • Information Gathering"
echo "  • Vulnerability Analysis"
echo "  • Web Application Analysis"
echo "  • etc."
echo ""
echo "If you still see directories (Desktop, Documents, etc.), manually fix it:"
echo "1. Right-click on the panel"
echo "2. Select 'Panel > Panel Preferences'"
echo "3. Go to 'Items' tab"
echo "4. Remove the current menu item"
echo "5. Click '+' and add 'Applications Menu'"
echo "6. Move it to the first position"