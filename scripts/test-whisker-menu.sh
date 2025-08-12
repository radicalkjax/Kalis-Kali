#!/bin/bash
# Test what's actually happening with the whisker menu

echo "Testing Whisker Menu Configuration"
echo "================================="

docker exec -u root kali-workspace bash << 'EOF'
echo "1. Checking current menu files:"
ls -la /etc/xdg/menus/
echo ""

echo "2. Checking if kali-menu is installed:"
dpkg -l | grep kali-menu

echo -e "\n3. Checking what xfce-applications.menu contains:"
grep -A5 -B5 "Menu\|Name" /etc/xdg/menus/xfce-applications.menu | head -30

echo -e "\n4. Checking applications-merged:"
ls -la /etc/xdg/menus/applications-merged/

echo -e "\n5. Checking user config:"
ls -la /root/.config/menus/ 2>/dev/null || echo "No user menu config"

echo -e "\n6. Testing menu merge:"
# Create a test XFCE menu that properly includes Kali
mkdir -p /root/.config/menus
cat > /root/.config/menus/xfce-applications.menu << 'EOMENU'
<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
  "http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">

<Menu>
    <Name>Xfce</Name>

    <DefaultAppDirs/>
    <DefaultDirectoryDirs/>
    <DefaultMergeDirs/>

    <Include>
        <Category>X-Xfce-Toplevel</Category>
    </Include>

    <!-- Include the Kali menu -->
    <MergeFile type="parent">/etc/xdg/menus/applications-merged/kali-applications.menu</MergeFile>

    <Layout>
        <Filename>xfce4-run.desktop</Filename>
        <Separator/>
        <Filename>xfce4-terminal-emulator.desktop</Filename>
        <Filename>xfce4-file-manager.desktop</Filename>
        <Filename>xfce4-web-browser.desktop</Filename>
        <Separator/>
        <Menuname>Settings</Menuname>
        <Separator/>
        <Merge type="all"/>
        <Separator/>
        <Filename>xfce4-about.desktop</Filename>
        <Filename>xfce4-session-logout.desktop</Filename>
    </Layout>
</Menu>
EOMENU

echo -e "\n7. Updating menu database:"
update-desktop-database /usr/share/applications
xdg-desktop-menu forceupdate

echo -e "\n8. Checking panel config for whiskermenu:"
if [ -f /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml ]; then
    grep -C3 "whiskermenu" /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
fi

echo -e "\n9. Restarting panel if running:"
if pgrep xfce4-panel > /dev/null; then
    xfce4-panel -r
    echo "Panel restarted"
else
    echo "Panel not running"
fi

echo -e "\nDone!"
EOF