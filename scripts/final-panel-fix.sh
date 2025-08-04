#!/bin/bash
# Final comprehensive panel fix

echo "Performing final comprehensive panel fix..."

# Step 1: Complete cleanup
docker exec -u kali kali-workspace bash -c '
    echo "=== Complete Panel Reset ==="
    
    # Kill everything
    xfce4-panel --quit 2>/dev/null || true
    pkill -9 xfce4-panel 2>/dev/null || true
    killall xfconfd 2>/dev/null || true
    sleep 2
    
    # Remove all configs and cache
    rm -rf ~/.config/xfce4/panel
    rm -rf ~/.config/xfce4/xfconf
    rm -rf ~/.cache/xfce4*
    rm -rf ~/.cache/sessions/*
    
    # Create fresh config structure
    mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml
    mkdir -p ~/.config/xfce4/panel
'

# Step 2: Install required packages if missing
docker exec -u root kali-workspace bash -c '
    apt-get update -qq
    apt-get install -y --no-install-recommends \
        xfce4-whiskermenu-plugin \
        xfce4-panel \
        kali-menu \
        kali-themes \
        kali-defaults 2>/dev/null
'

# Step 3: Apply the vertical panel configuration
docker exec -u kali kali-workspace bash -c '
    # Create the panel XML config
    cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="dark-mode" type="bool" value="true"/>
    <property name="panel-1" type="empty">
      <property name="autohide-behavior" type="uint" value="0"/>
      <property name="background-alpha" type="uint" value="80"/>
      <property name="background-style" type="uint" value="1"/>
      <property name="disable-struts" type="bool" value="false"/>
      <property name="enter-opacity" type="uint" value="100"/>
      <property name="icon-size" type="uint" value="0"/>
      <property name="leave-opacity" type="uint" value="100"/>
      <property name="length" type="uint" value="100"/>
      <property name="length-adjust" type="bool" value="true"/>
      <property name="mode" type="uint" value="1"/>
      <property name="nrows" type="uint" value="1"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/>
        <value type="int" value="15"/>
        <value type="int" value="16"/>
        <value type="int" value="17"/>
      </property>
      <property name="position" type="string" value="p=1;x=0;y=0"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="size" type="uint" value="48"/>
      <property name="span-monitors" type="bool" value="false"/>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="clipman" type="empty">
      <property name="tweaks" type="empty">
        <property name="never-confirm-history-clear" type="bool" value="false"/>
      </property>
    </property>
    <property name="plugin-1" type="string" value="whiskermenu">
      <property name="button-icon" type="string" value="kali-menu"/>
      <property name="button-single-row" type="bool" value="false"/>
      <property name="button-title" type="string" value="Applications"/>
      <property name="command-hibernate" type="string" value="xfce4-session-logout --hibernate"/>
      <property name="command-lockscreen" type="string" value="xflock4"/>
      <property name="command-logout" type="string" value="xfce4-session-logout"/>
      <property name="command-logoutuser" type="string" value="xfce4-session-logout --logout --fast"/>
      <property name="command-menueditor" type="string" value="menulibre"/>
      <property name="command-profile" type="string" value="mugshot"/>
      <property name="command-restart" type="string" value="xfce4-session-logout --reboot --fast"/>
      <property name="command-settings" type="string" value="xfce4-settings-manager"/>
      <property name="command-shutdown" type="string" value="xfce4-session-logout --halt --fast"/>
      <property name="command-suspend" type="string" value="xfce4-session-logout --suspend"/>
      <property name="command-switchuser" type="string" value="dm-tool switch-to-greeter"/>
      <property name="confirm-session-command" type="bool" value="false"/>
      <property name="custom-menu-file" type="string" value=""/>
      <property name="display-description" type="bool" value="false"/>
      <property name="favorites-in-recent" type="bool" value="true"/>
      <property name="hover-switch-category" type="bool" value="false"/>
      <property name="launcher-show-description" type="bool" value="false"/>
      <property name="launcher-show-name" type="bool" value="true"/>
      <property name="launcher-show-tooltip" type="bool" value="true"/>
      <property name="menu-height" type="int" value="500"/>
      <property name="menu-width" type="int" value="500"/>
      <property name="position-categories-alternate" type="bool" value="false"/>
      <property name="position-commands-alternate" type="bool" value="false"/>
      <property name="position-search-alternate" type="bool" value="true"/>
      <property name="recent-items-max" type="int" value="25"/>
      <property name="show-button-title" type="bool" value="false"/>
      <property name="show-command-hibernate" type="bool" value="false"/>
      <property name="show-command-lockscreen" type="bool" value="true"/>
      <property name="show-command-logout" type="bool" value="true"/>
      <property name="show-command-logoutuser" type="bool" value="false"/>
      <property name="show-command-menueditor" type="bool" value="true"/>
      <property name="show-command-profile" type="bool" value="true"/>
      <property name="show-command-restart" type="bool" value="true"/>
      <property name="show-command-settings" type="bool" value="true"/>
      <property name="show-command-shutdown" type="bool" value="true"/>
      <property name="show-command-suspend" type="bool" value="false"/>
      <property name="show-command-switchuser" type="bool" value="false"/>
      <property name="stay-on-focus-out" type="bool" value="false"/>
      <property name="view-mode" type="int" value="2"/>
    </property>
    <property name="plugin-15" type="string" value="separator">
      <property name="expand" type="bool" value="true"/>
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-16" type="string" value="tasklist">
      <property name="flat-buttons" type="bool" value="true"/>
      <property name="grouping" type="uint" value="1"/>
      <property name="include-all-monitors" type="bool" value="true"/>
      <property name="include-all-workspaces" type="bool" value="false"/>
      <property name="middle-click" type="uint" value="0"/>
      <property name="show-handle" type="bool" value="false"/>
      <property name="show-labels" type="bool" value="false"/>
      <property name="show-only-minimized" type="bool" value="false"/>
      <property name="show-wireframes" type="bool" value="false"/>
      <property name="sort-order" type="uint" value="1"/>
      <property name="switch-workspace-on-unminimize" type="bool" value="true"/>
      <property name="window-scrolling" type="bool" value="true"/>
    </property>
    <property name="plugin-17" type="string" value="systray">
      <property name="hide-new-items" type="bool" value="false"/>
      <property name="icon-size" type="int" value="0"/>
      <property name="known-legacy-items" type="array">
        <value type="string" value="networkmanager applet"/>
      </property>
      <property name="single-row" type="bool" value="false"/>
      <property name="size-max" type="uint" value="22"/>
      <property name="square-icons" type="bool" value="true"/>
    </property>
  </property>
</channel>
EOF

    # Set permissions
    chmod 644 ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
    
    # Start xfconfd to handle the config
    export DISPLAY=host.docker.internal:0
    xfconfd --replace &
    sleep 1
    
    # Start the panel
    xfce4-panel --disable-wm-check &
    
    sleep 3
    
    echo "=== Panel Configuration Applied ==="
    echo "The panel should now be:"
    echo "✓ Vertical on the left side (48px wide)"
    echo "✓ With Kali whisker menu"
    echo "✓ Task list and system tray"
    echo "✓ Dark theme with 80% opacity"
'

echo ""
echo "Panel fix complete!"
echo ""
echo "If the panel is STILL not vertical, there might be a display issue."
echo "Try these commands:"
echo "1. docker exec -u kali kali-workspace xfce4-panel -r"
echo "2. docker restart kali-workspace"