#!/bin/bash
# Quick fix to apply Kali menu merge

echo "Applying Kali menu fix..."

docker exec -u root kali-workspace bash << 'EOF'
# Create the merged menu file
mkdir -p /root/.config/menus
mkdir -p /home/kali/.config/menus

# Create merged menu that explicitly includes Kali menu
cat > /root/.config/menus/xfce-applications.menu << 'EOMENU'
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

    <!-- CRITICAL: Explicitly merge the Kali menu -->
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

# Copy to kali user
cp /root/.config/menus/xfce-applications.menu /home/kali/.config/menus/
chown -R kali:kali /home/kali/.config/menus

# Update databases
update-desktop-database /usr/share/applications
update-menus

# Clear caches
rm -rf /root/.cache/menus/*
rm -rf /home/kali/.cache/menus/*

# Restart panel to reload menu
pkill -USR1 xfce4-panel || true
sleep 1
xfce4-panel -r || true

echo "Menu fix applied! The whisker menu should now show Kali categories."
EOF

echo "Done! Check the whisker menu now."