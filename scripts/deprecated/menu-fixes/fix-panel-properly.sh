#!/bin/bash
# Properly fix the XFCE panel with Applications Menu

echo "Properly fixing XFCE Panel"
echo "========================="

# Check if container is running
if ! docker ps | grep -q kali-workspace; then
    echo "Error: kali-workspace container is not running"
    echo "Start it with: docker-compose up -d kali"
    exit 1
fi

docker exec kali-workspace bash -c '
    echo "Cleaning up defunct processes..."
    # Kill all xfce4-panel processes
    pkill -9 xfce4-panel 2>/dev/null
    sleep 2
    
    echo "Checking if kali user exists..."
    if ! id kali &>/dev/null; then
        echo "Creating kali user..."
        useradd -m -s /bin/bash kali
        echo "kali:kali" | chpasswd
        usermod -aG sudo kali
    fi
    
    echo "Setting up for root user (current user)..."
    HOME_DIR=/root
    
    echo "Cleaning configuration..."
    rm -rf $HOME_DIR/.config/xfce4/panel
    rm -rf $HOME_DIR/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
    rm -rf $HOME_DIR/.cache/sessions/xfce4-panel*
    
    echo "Creating panel directories..."
    mkdir -p $HOME_DIR/.config/xfce4/panel
    mkdir -p $HOME_DIR/.config/xfce4/xfconf/xfce-perchannel-xml
    
    echo "Installing required packages..."
    apt-get update >/dev/null 2>&1
    apt-get install -y kali-menu xfce4-panel xfce4-whiskermenu-plugin >/dev/null 2>&1
    
    echo "Creating default panel configuration..."
    cat > $HOME_DIR/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=8;x=683;y=754"/>
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
        <value type="int" value="7"/>
      </property>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="whiskermenu"/>
    <property name="plugin-2" type="string" value="separator">
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-3" type="string" value="launcher">
      <property name="items" type="array">
        <value type="string" value="xfce4-terminal.desktop"/>
      </property>
    </property>
    <property name="plugin-4" type="string" value="separator">
      <property name="expand" type="bool" value="true"/>
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-5" type="string" value="systray"/>
    <property name="plugin-6" type="string" value="separator">
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-7" type="string" value="clock">
      <property name="digital-format" type="string" value="%I:%M %p"/>
    </property>
  </property>
</channel>
EOF
    
    echo "Ensuring menu files exist..."
    if [ -f /etc/xdg/menus/kali-applications.menu ]; then
        ln -sf /etc/xdg/menus/kali-applications.menu /etc/xdg/menus/xfce-applications.menu
    fi
    
    echo "Starting panel..."
    export DISPLAY=host.docker.internal:0
    export HOME=$HOME_DIR
    xfce4-panel --disable-wm-check &
    
    sleep 3
    echo "Panel started successfully"
'

echo ""
echo "Panel should now be working with:"
echo "- Whisker Menu (better than standard Applications Menu)"
echo "- Terminal launcher"
echo "- System tray"
echo "- Clock"
echo ""
echo "Click on the menu icon to see all Kali tools organized by category!"