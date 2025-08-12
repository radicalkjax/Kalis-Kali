#!/bin/bash

# Comprehensive Menu Configuration Script
# Consolidates ALL menu/panel fix scripts into one reliable solution

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_msg() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_error() {
    echo -e "${RED}[!]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[*]${NC} $1"
}

print_msg "Configuring Kali Menu System"
echo "============================="

# Step 1: Ensure kali-menu package is installed
print_msg "Checking kali-menu installation..."
if ! dpkg -l | grep -q "^ii  kali-menu"; then
    print_warning "kali-menu not installed, installing now..."
    apt-get update >/dev/null 2>&1
    apt-get install -y kali-menu kali-desktop-xfce >/dev/null 2>&1
fi

# Step 2: Install Whisker Menu plugin if missing
print_msg "Checking Whisker Menu plugin..."
if ! dpkg -l | grep -q "^ii  xfce4-whiskermenu-plugin"; then
    print_warning "Installing Whisker Menu plugin..."
    apt-get install -y xfce4-whiskermenu-plugin >/dev/null 2>&1
fi

# Step 3: Create necessary directories
print_msg "Creating menu directories..."
mkdir -p /etc/xdg/menus/applications-merged
mkdir -p /home/kali/.config/xfce4/panel
mkdir -p /home/kali/.config/xfce4/xfconf/xfce-perchannel-xml
mkdir -p /home/kali/.config/menus

# Step 4: Update kali menu if command exists
if [ -x /usr/share/kali-menu/update-kali-menu ]; then
    print_msg "Updating Kali menu database..."
    /usr/share/kali-menu/update-kali-menu
fi

# Step 5: Configure XFCE to merge Kali menus
print_msg "Configuring XFCE menu integration..."
cat > /etc/xdg/menus/xfce-applications.menu << 'EOF'
<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
  "http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">
<Menu>
    <Name>Xfce</Name>
    
    <!-- Read standard entries -->
    <DefaultAppDirs/>
    <DefaultDirectoryDirs/>
    <DefaultMergeDirs/>
    
    <!-- Merge Kali menu -->
    <MergeFile type="parent">/etc/xdg/menus/applications-merged/kali-applications.menu</MergeFile>
    
    <!-- Define Categories -->
    <Include>
        <Category>X-Xfce-Toplevel</Category>
    </Include>

    <!-- Layout -->
    <Layout>
        <Filename>xfce4-run.desktop</Filename>
        <Separator/>
        <Filename>exo-terminal-emulator.desktop</Filename>
        <Filename>exo-file-manager.desktop</Filename>
        <Filename>exo-web-browser.desktop</Filename>
        <Separator/>
        <Menuname>Kali</Menuname>
        <Separator/>
        <Menuname>Settings</Menuname>
        <Separator/>
        <Menuname>System</Menuname>
        <Separator/>
        <Filename>xfce4-session-logout.desktop</Filename>
    </Layout>
    
    <!-- Kali Categories -->
    <Menu>
        <Name>Kali</Name>
        <Directory>kali.directory</Directory>
        <Include>
            <Category>kali</Category>
        </Include>
        
        <!-- Include all Kali subcategories -->
        <Menu>
            <Name>Information Gathering</Name>
            <Directory>kali-info-gathering.directory</Directory>
            <Include><Category>kali-info-gathering</Category></Include>
        </Menu>
        
        <Menu>
            <Name>Vulnerability Analysis</Name>
            <Directory>kali-vuln-analysis.directory</Directory>
            <Include><Category>kali-vuln-analysis</Category></Include>
        </Menu>
        
        <Menu>
            <Name>Web Application Analysis</Name>
            <Directory>kali-webapp-analysis.directory</Directory>
            <Include><Category>kali-webapp-analysis</Category></Include>
        </Menu>
        
        <Menu>
            <Name>Password Attacks</Name>
            <Directory>kali-password-attacks.directory</Directory>
            <Include><Category>kali-password-attacks</Category></Include>
        </Menu>
        
        <Menu>
            <Name>Wireless Attacks</Name>
            <Directory>kali-wireless-attacks.directory</Directory>
            <Include><Category>kali-wireless-attacks</Category></Include>
        </Menu>
        
        <Menu>
            <Name>Reverse Engineering</Name>
            <Directory>kali-reverse-engineering.directory</Directory>
            <Include><Category>kali-reverse-engineering</Category></Include>
        </Menu>
        
        <Menu>
            <Name>Exploitation Tools</Name>
            <Directory>kali-exploitation-tools.directory</Directory>
            <Include><Category>kali-exploitation-tools</Category></Include>
        </Menu>
        
        <Menu>
            <Name>Forensics</Name>
            <Directory>kali-forensics.directory</Directory>
            <Include><Category>kali-forensics</Category></Include>
        </Menu>
        
        <Menu>
            <Name>Reporting Tools</Name>
            <Directory>kali-reporting-tools.directory</Directory>
            <Include><Category>kali-reporting-tools</Category></Include>
        </Menu>
        
        <Menu>
            <Name>Social Engineering</Name>
            <Directory>kali-social-engineering.directory</Directory>
            <Include><Category>kali-social-engineering</Category></Include>
        </Menu>
    </Menu>
</Menu>
EOF

# Step 6: Create user menu configuration
print_msg "Setting up user menu configuration..."
cat > /home/kali/.config/menus/xfce-applications.menu << 'EOF'
<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
  "http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">
<Menu>
    <Name>Xfce</Name>
    <MergeFile type="parent">/etc/xdg/menus/xfce-applications.menu</MergeFile>
</Menu>
EOF

# Step 7: Configure Whisker Menu
print_msg "Configuring Whisker Menu..."
cat > /home/kali/.config/xfce4/panel/whiskermenu-1.rc << 'EOF'
favorites=exo-terminal-emulator.desktop,exo-file-manager.desktop,firefox-esr.desktop,burpsuite.desktop,metasploit.desktop,wireshark.desktop
recent=
button-icon=kali-menu
button-single-row=false
show-button-title=true
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
EOF

# Step 8: Configure Panel
print_msg "Configuring XFCE Panel..."
cat > /home/kali/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=6;x=0;y=0"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="size" type="uint" value="48"/>
      <property name="length" type="uint" value="100"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/>
        <value type="int" value="2"/>
        <value type="int" value="3"/>
        <value type="int" value="4"/>
        <value type="int" value="5"/>
        <value type="int" value="6"/>
        <value type="int" value="7"/>
        <value type="int" value="8"/>
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
        <value type="string" value="exo-terminal-emulator.desktop"/>
      </property>
    </property>
    <property name="plugin-4" type="string" value="launcher">
      <property name="items" type="array">
        <value type="string" value="firefox-esr.desktop"/>
      </property>
    </property>
    <property name="plugin-5" type="string" value="separator">
      <property name="style" type="uint" value="0"/>
      <property name="expand" type="bool" value="true"/>
    </property>
    <property name="plugin-6" type="string" value="systray">
      <property name="show-frame" type="bool" value="false"/>
      <property name="icon-size" type="int" value="22"/>
    </property>
    <property name="plugin-7" type="string" value="clock">
      <property name="digital-format" type="string" value="%I:%M %p"/>
    </property>
    <property name="plugin-8" type="string" value="actions">
      <property name="appearance" type="uint" value="0"/>
      <property name="items" type="array">
        <value type="string" value="+lock-screen"/>
        <value type="string" value="+switch-user"/>
        <value type="string" value="+separator"/>
        <value type="string" value="+suspend"/>
        <value type="string" value="+hibernate"/>
        <value type="string" value="+separator"/>
        <value type="string" value="+shutdown"/>
        <value type="string" value="+restart"/>
        <value type="string" value="+separator"/>
        <value type="string" value="+logout"/>
      </property>
    </property>
  </property>
</channel>
EOF

# Step 9: Set correct ownership
print_msg "Setting correct file ownership..."
chown -R kali:kali /home/kali/.config

# Step 10: Update desktop database
print_msg "Updating desktop database..."
update-desktop-database /usr/share/applications 2>/dev/null || true

# Step 11: Clear cache
print_msg "Clearing menu cache..."
rm -rf /home/kali/.cache/xfce4/xfce4-appfinder
rm -rf /home/kali/.cache/menus

# Step 12: Verify configuration
print_msg "Verifying configuration..."

# Check if kali menu file exists
if [ -f /etc/xdg/menus/applications-merged/kali-applications.menu ]; then
    print_msg "✓ Kali menu file found"
else
    print_warning "⚠ Kali menu file missing - menu may not work properly"
fi

# Check if Whisker menu is configured
if [ -f /home/kali/.config/xfce4/panel/whiskermenu-1.rc ]; then
    print_msg "✓ Whisker menu configured"
else
    print_warning "⚠ Whisker menu configuration missing"
fi

# Check panel configuration
if [ -f /home/kali/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml ]; then
    print_msg "✓ Panel configured"
else
    print_warning "⚠ Panel configuration missing"
fi

print_msg "Menu configuration complete!"

# Step 13: Ensure panel tools are installed
print_msg "Checking panel tool requirements..."
if [ -f /home/kali/scripts/utils/ensure-panel-tools.sh ]; then
    /home/kali/scripts/utils/ensure-panel-tools.sh >/dev/null 2>&1 || print_warning "Some panel tools may be missing"
fi

# Step 14: Configure panel launcher icons
print_msg "Configuring panel launcher icons..."
if [ -f /home/kali/scripts/utils/configure-panel-icons.sh ]; then
    /home/kali/scripts/utils/configure-panel-icons.sh /home/kali/.config >/dev/null 2>&1 || print_warning "Some icons may not be configured"
fi

echo ""
print_msg "Desktop configuration complete!"
echo ""
print_msg "Changes will take effect when desktop is restarted"
print_msg "If menu still doesn't work, try:"
echo "  1. Restart the panel: xfce4-panel -r"
echo "  2. Logout and login again"
echo "  3. Run: ./scripts/core/rebuild.sh"