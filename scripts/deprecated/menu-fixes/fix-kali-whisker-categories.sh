#!/bin/bash
# Fix Whisker menu to show Kali categories

echo "Fixing Kali categories in Whisker menu..."

# Ensure container is running
if ! docker ps | grep -q kali-workspace; then
    echo "Error: kali-workspace container is not running"
    exit 1
fi

# Fix the menu configuration
docker exec -u root kali-workspace bash << 'EOF'
echo "Creating proper XFCE menu configuration..."

# Create menu directory
mkdir -p /root/.config/menus
mkdir -p /home/kali/.config/menus

# Create a menu file that properly includes Kali categories
cat > /root/.config/menus/xfce-applications.menu << 'MENU'
<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
  "http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">
<Menu>
    <Name>Xfce</Name>
    
    <!-- Include the Kali menu -->
    <MergeFile type="parent">/etc/xdg/menus/applications-merged/kali-applications.menu</MergeFile>
    
    <!-- Standard directories -->
    <DefaultAppDirs/>
    <DefaultDirectoryDirs/>
    <DefaultMergeDirs/>
    
    <!-- Include all applications -->
    <Include>
        <All/>
    </Include>
</Menu>
MENU

# Copy to kali user
cp /root/.config/menus/xfce-applications.menu /home/kali/.config/menus/
chown -R kali:kali /home/kali/.config/menus

# Update Kali menu
echo "Updating Kali menu..."
if [ -x /usr/share/kali-menu/update-kali-menu ]; then
    /usr/share/kali-menu/update-kali-menu
fi

# Clear all caches
echo "Clearing menu caches..."
rm -rf /root/.cache/menus/*
rm -rf /home/kali/.cache/menus/*
rm -rf /root/.cache/xfce4/panel/*
rm -rf /home/kali/.cache/xfce4/panel/*

# Update desktop database
echo "Updating desktop database..."
update-desktop-database -v /usr/share/applications

# Force menu update
xdg-desktop-menu forceupdate

# Restart panel
echo "Restarting panel..."
pkill xfce4-panel || true
sleep 2

echo "Done! The Kali categories should now appear in Whisker menu."
EOF

echo ""
echo "Menu fix complete!"
echo ""
echo "If categories still don't appear:"
echo "1. Right-click on the Whisker menu icon"
echo "2. Select 'Properties'"
echo "3. Check 'Load hierarchy'"
echo "4. Close and reopen the menu"