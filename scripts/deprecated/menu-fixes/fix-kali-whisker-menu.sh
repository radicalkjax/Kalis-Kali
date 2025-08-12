#!/bin/bash
# Fix Kali whisker menu to show Kali categories

echo "Fixing Kali Whisker Menu"
echo "========================"

docker exec -u root kali-workspace bash << 'EOF'
# 1. Ensure kali-menu is installed
if ! dpkg -l | grep -q "^ii  kali-menu "; then
    echo "Installing kali-menu..."
    apt-get update -qq
    apt-get install -y kali-menu
fi

# 2. The key issue: XFCE whisker menu doesn't properly merge the applications-merged directory
# We need to create a merged menu file that includes both XFCE and Kali menus

echo "Creating merged menu configuration..."

# Backup original
cp /etc/xdg/menus/xfce-applications.menu /etc/xdg/menus/xfce-applications.menu.backup

# Create a new menu that explicitly includes the Kali menu
cat > /etc/xdg/menus/xfce-applications.menu << 'EOMENU'
<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
  "http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">

<Menu>
    <Name>Xfce</Name>

    <DefaultAppDirs/>
    <DefaultDirectoryDirs/>
    <DefaultMergeDirs/>

    <!-- Include standard XFCE items -->
    <Include>
        <Category>X-Xfce-Toplevel</Category>
    </Include>

    <!-- Explicitly merge the Kali menu -->
    <MergeFile type="parent">/etc/xdg/menus/applications-merged/kali-applications.menu</MergeFile>

    <!-- Standard Categories -->
    <Menu>
        <Name>Settings</Name>
        <Directory>xfce-settings.directory</Directory>
        <Include>
            <Or>
                <Category>Settings</Category>
                <Category>DesktopSettings</Category>
            </Or>
        </Include>
    </Menu>

    <Menu>
        <Name>Accessories</Name>
        <Directory>xfce-accessories.directory</Directory>
        <Include>
            <Or>
                <Category>Accessibility</Category>
                <Category>Core</Category>
                <Category>Legacy</Category>
                <Category>Utility</Category>
            </Or>
        </Include>
    </Menu>

    <Menu>
        <Name>Development</Name>
        <Directory>xfce-development.directory</Directory>
        <Include>
            <Category>Development</Category>
        </Include>
    </Menu>

    <Menu>
        <Name>Education</Name>
        <Directory>xfce-education.directory</Directory>
        <Include>
            <Category>Education</Category>
        </Include>
    </Menu>

    <Menu>
        <Name>Games</Name>
        <Directory>xfce-games.directory</Directory>
        <Include>
            <Category>Game</Category>
        </Include>
    </Menu>

    <Menu>
        <Name>Graphics</Name>
        <Directory>xfce-graphics.directory</Directory>
        <Include>
            <Category>Graphics</Category>
        </Include>
    </Menu>

    <Menu>
        <Name>Multimedia</Name>
        <Directory>xfce-multimedia.directory</Directory>
        <Include>
            <Or>
                <Category>Audio</Category>
                <Category>Video</Category>
                <Category>AudioVideo</Category>
            </Or>
        </Include>
    </Menu>

    <Menu>
        <Name>Network</Name>
        <Directory>xfce-network.directory</Directory>
        <Include>
            <Category>Network</Category>
        </Include>
    </Menu>

    <Menu>
        <Name>Office</Name>
        <Directory>xfce-office.directory</Directory>
        <Include>
            <Category>Office</Category>
        </Include>
    </Menu>

    <Menu>
        <Name>System</Name>
        <Directory>xfce-system.directory</Directory>
        <Include>
            <Or>
                <Category>Emulator</Category>
                <Category>System</Category>
            </Or>
        </Include>
    </Menu>

    <Menu>
        <Name>Other</Name>
        <Directory>xfce-other.directory</Directory>
        <OnlyUnallocated/>
        <Include>
            <All/>
        </Include>
    </Menu>

    <Layout>
        <Merge type="menus"/>
        <Separator/>
        <Menuname>Settings</Menuname>
        <Menuname>Accessories</Menuname>
        <Menuname>Development</Menuname>
        <Menuname>Education</Menuname>
        <Menuname>Games</Menuname>
        <Menuname>Graphics</Menuname>
        <Menuname>Multimedia</Menuname>
        <Menuname>Network</Menuname>
        <Menuname>Office</Menuname>
        <Menuname>System</Menuname>
        <Menuname>Other</Menuname>
    </Layout>
</Menu>
EOMENU

# 3. Update databases
echo "Updating menu databases..."
update-desktop-database /usr/share/applications
update-menus

# 4. Clear caches
echo "Clearing menu caches..."
rm -rf /root/.cache/menus/*
rm -rf /home/kali/.cache/menus/*
rm -rf /root/.cache/xfce4/*
rm -rf /home/kali/.cache/xfce4/*

# 5. Restart panel if running
if pgrep xfce4-panel > /dev/null; then
    echo "Restarting panel..."
    xfce4-panel -r
fi

echo "Done! The whisker menu should now show:"
echo "- Reconnaissance"
echo "- Persistence"
echo "- Discovery"
echo "- Collection"
echo "- Impact"
echo "- Forensics"
echo "- And all other Kali categories"
EOF

echo ""
echo "Fix complete! The Kali categories should now appear in the whisker menu."