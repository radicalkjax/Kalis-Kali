#!/bin/bash
# Force vertical panel with whisker menu

echo "Force-fixing vertical panel..."

# First, kill all panel processes
docker exec -u kali kali-workspace bash -c 'xfce4-panel --quit 2>/dev/null || true; pkill -9 xfce4-panel 2>/dev/null || true'
sleep 2

# Now apply the fix with whiskermenu explicitly
docker exec -u kali kali-workspace bash -c '
    # Remove old config
    rm -rf ~/.config/xfce4/panel
    rm -f ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
    
    # Create directories
    mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml
    mkdir -p ~/.config/xfce4/panel/launcher-1
    
    # Create minimal vertical panel config with whiskermenu
    cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=1;x=0;y=0"/>
      <property name="size" type="uint" value="48"/>
      <property name="mode" type="uint" value="1"/>
      <property name="length" type="uint" value="100"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="background-style" type="uint" value="1"/>
      <property name="background-alpha" type="uint" value="80"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/>
        <value type="int" value="2"/>
        <value type="int" value="3"/>
      </property>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="whiskermenu">
      <property name="button-icon" type="string" value="kali-menu"/>
      <property name="show-button-title" type="bool" value="false"/>
    </property>
    <property name="plugin-2" type="string" value="tasklist">
      <property name="show-labels" type="bool" value="false"/>
    </property>
    <property name="plugin-3" type="string" value="systray"/>
  </property>
</channel>
EOF
    
    # Start panel
    export DISPLAY=host.docker.internal:0
    xfce4-panel --disable-wm-check &
'

sleep 3

# Verify it started
docker exec -u kali kali-workspace bash -c 'ps aux | grep xfce4-panel | grep -v grep'

echo ""
echo "Panel should now be vertical on the left with:"
echo "- Kali whisker menu"
echo "- Task list"
echo "- System tray"
echo ""
echo "If you still don't see it vertical, the panel might be caching the old config."
echo "Try: docker exec -u kali kali-workspace xfce4-panel -r"