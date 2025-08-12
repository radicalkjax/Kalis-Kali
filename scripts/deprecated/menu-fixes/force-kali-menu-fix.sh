#!/bin/bash
# Force fix for Kali menu in Whisker menu
# This script applies multiple fixes to ensure all Kali categories show up

echo "Forcing Kali menu fix..."

# Ensure container is running
if ! docker ps | grep -q kali-workspace; then
    echo "Error: kali-workspace container is not running"
    exit 1
fi

docker exec -u root kali-workspace bash << 'EOF'
echo "=== Kali Menu Force Fix ==="

# 1. Verify Kali menu file exists
echo "1. Checking Kali menu file..."
if [ ! -f /etc/xdg/menus/applications-merged/kali-applications.menu ]; then
    echo "ERROR: Kali menu file missing!"
    exit 1
else
    echo "✓ Kali menu file exists"
fi

# 2. Create XFCE menu merge
echo "2. Creating XFCE menu merge..."
mkdir -p /root/.config/menus
cat > /root/.config/menus/xfce-applications.menu << 'MENU'
<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
  "http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">
<Menu>
    <Name>Xfce</Name>
    <DefaultAppDirs/>
    <DefaultDirectoryDirs/>
    <DefaultMergeDirs/>
    
    <!-- Force merge Kali menu -->
    <MergeFile type="parent">/etc/xdg/menus/applications-merged/kali-applications.menu</MergeFile>
    
    <!-- Include everything -->
    <Include>
        <All/>
    </Include>
</Menu>
MENU

# Copy to kali user too
cp /root/.config/menus/xfce-applications.menu /home/kali/.config/menus/
chown -R kali:kali /home/kali/.config/menus

echo "✓ Menu merge created"

# 3. Configure Whisker menu properly
echo "3. Configuring Whisker menu..."
mkdir -p /root/.config/xfce4/panel
mkdir -p /home/kali/.config/xfce4/panel

# Find the actual whiskermenu plugin number
WHISKER_NUM=$(xfconf-query -c xfce4-panel -p /plugins -l 2>/dev/null | grep whiskermenu | grep -oE 'plugin-[0-9]+' | grep -oE '[0-9]+' | head -1)
if [ -z "$WHISKER_NUM" ]; then
    echo "Warning: Could not find whiskermenu plugin number, using default 1"
    WHISKER_NUM="1"
fi

echo "Found whiskermenu plugin number: $WHISKER_NUM"

# Create whiskermenu config with correct filename
cat > /root/.config/xfce4/panel/whiskermenu-${WHISKER_NUM}.rc << 'WHISK'
favorites=xfce4-terminal.desktop
recent=
button-icon=kali-menu
button-single-row=false
show-button-title=false
show-button-icon=true
launcher-show-name=true
launcher-show-description=true
launcher-show-tooltip=true
item-icon-size=2
hover-switch-category=false
category-show-name=true
category-icon-size=1
load-hierarchy=true
view-as-icons=false
default-category=0
recent-items-max=10
favorites-in-recent=true
position-search-alternate=true
position-commands-alternate=false
position-categories-alternate=true
stay-on-focus-out=false
confirm-session-command=true
menu-width=450
menu-height=550
menu-opacity=100
command-settings=xfce4-settings-manager
show-command-settings=true
command-lockscreen=xflock4
show-command-lockscreen=true
command-switchuser=dm-tool switch-to-greeter
show-command-switchuser=false
command-logoutuser=xfce4-session-logout --logout --fast
show-command-logoutuser=false
command-restart=xfce4-session-logout --reboot --fast
show-command-restart=false
command-shutdown=xfce4-session-logout --halt --fast
show-command-shutdown=false
command-suspend=xfce4-session-logout --suspend
show-command-suspend=false
command-hibernate=xfce4-session-logout --hibernate
show-command-hibernate=false
command-logout=xfce4-session-logout
show-command-logout=true
command-menueditor=menulibre
show-command-menueditor=true
command-profile=mugshot
show-command-profile=false
search-actions=5
WHISK

# Copy config for both users
cp /root/.config/xfce4/panel/whiskermenu-${WHISKER_NUM}.rc /home/kali/.config/xfce4/panel/
chown -R kali:kali /home/kali/.config/xfce4/panel
echo "✓ Whisker menu configured"

# 4. Clear ALL caches
echo "4. Clearing all caches..."
rm -rf /root/.cache/menus/*
rm -rf /root/.cache/xfce4/*
rm -rf /home/kali/.cache/menus/*
rm -rf /home/kali/.cache/xfce4/*
rm -rf /root/.cache/sessions/*
rm -rf /home/kali/.cache/sessions/*
echo "✓ Caches cleared"

# 5. Update menu database
echo "5. Updating menu database..."
update-desktop-database /usr/share/applications
update-menus
xdg-desktop-menu forceupdate
echo "✓ Menu database updated"

# 6. Set xfconf properties for whiskermenu
echo "6. Setting xfconf properties..."
if command -v xfconf-query >/dev/null 2>&1; then
    # Set load-hierarchy property
    xfconf-query -c xfce4-panel -p /plugins/plugin-${WHISKER_NUM}/load-hierarchy -t bool -s true --create 2>/dev/null || true
    echo "✓ xfconf properties set"
else
    echo "! xfconf-query not available, skipping"
fi

# 7. Kill and restart panel
echo "7. Restarting panel..."
pkill xfce4-panel
sleep 2
DISPLAY=:0 xfce4-panel &
disown
sleep 3
echo "✓ Panel restarted"

# 8. Verify Kali categories are available
echo "8. Verifying Kali categories..."
KALI_CATS=$(ls /usr/share/desktop-directories/kali-*.directory 2>/dev/null | wc -l)
echo "Found $KALI_CATS Kali category files"

# 9. Check installed kali-tools packages
echo "9. Checking installed packages..."
INSTALLED=$(dpkg -l | grep -E '^ii  kali-tools-' | wc -l)
echo "Installed Kali tool packages: $INSTALLED"

echo ""
echo "=== Fix Complete ==="
echo "The Whisker menu should now show all Kali categories."
echo "If not, try:"
echo "1. Right-click Whisker menu → Properties"
echo "2. Ensure 'Load hierarchy' is checked"
echo "3. Close and reopen the menu"
EOF

echo ""
echo "Fix applied. Check the Whisker menu now."