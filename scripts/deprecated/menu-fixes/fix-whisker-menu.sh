#!/bin/bash
# Fix the Whisker menu to show all Kali categories

echo "Fixing Whisker menu with all Kali categories..."

docker exec kali-workspace bash << 'EOF'
# Ensure we're running as root for system changes
if [ "$EUID" -ne 0 ]; then 
    echo "Switching to root..."
    exec sudo bash "$0" "$@"
fi

echo "Installing Kali menu packages..."
apt-get update -qq
apt-get install -y \
    kali-menu \
    kali-desktop-xfce \
    kali-themes \
    kali-defaults \
    menu \
    menu-xdg \
    desktop-file-utils \
    xdg-utils 2>/dev/null

echo "Installing Kali tool categories to populate menu..."
# Install a minimal set of tools to ensure categories appear
apt-get install -y \
    nmap \
    dirb \
    nikto \
    sqlmap \
    john \
    hashcat \
    aircrack-ng \
    metasploit-framework \
    burpsuite \
    wireshark \
    tcpdump \
    binwalk \
    foremost \
    autopsy 2>/dev/null || true

# Create desktop entries for missing categories
echo "Creating entries for missing categories..."

# 05 - Persistence
if ! grep -q "X-Kali-05-Persistence" /usr/share/applications/*.desktop 2>/dev/null; then
    cat > /usr/share/applications/kali-persistence-tools.desktop <<EODESKTOP
[Desktop Entry]
Type=Application
Name=Persistence Tools
Comment=Post-exploitation persistence tools
Icon=kali-menu
Exec=xfce4-terminal -e "bash -c 'echo Persistence Tools; echo Use these tools for maintaining access; read'"
Categories=X-Kali-05-Persistence;05-01-os-backdoors;
EODESKTOP
fi

# 09 - Discovery  
if ! grep -q "X-Kali-09-Discovery" /usr/share/applications/*.desktop 2>/dev/null; then
    cat > /usr/share/applications/kali-discovery-tools.desktop <<EODESKTOP
[Desktop Entry]
Type=Application  
Name=Discovery Tools
Comment=Network and service discovery
Icon=network-workgroup
Exec=xfce4-terminal -e "bash -c 'echo Discovery Tools; echo Tools like nmap for network discovery; read'"
Categories=X-Kali-09-Discovery;09-01-network-scanners;
EODESKTOP
fi

# 11 - Collection
if ! grep -q "X-Kali-11-Collection" /usr/share/applications/*.desktop 2>/dev/null; then
    cat > /usr/share/applications/kali-collection-tools.desktop <<EODESKTOP
[Desktop Entry]
Type=Application
Name=Collection Tools  
Comment=Data collection and exfiltration
Icon=folder-download
Exec=xfce4-terminal -e "bash -c 'echo Collection Tools; echo Data gathering utilities; read'"
Categories=X-Kali-11-Collection;11-01-data-tools;
EODESKTOP
fi

# 14 - Impact
if ! grep -q "X-Kali-14-Impact" /usr/share/applications/*.desktop 2>/dev/null; then
    cat > /usr/share/applications/kali-impact-tools.desktop <<EODESKTOP
[Desktop Entry]
Type=Application
Name=Impact Tools
Comment=System impact and DoS tools  
Icon=dialog-warning
Exec=xfce4-terminal -e "bash -c 'echo Impact Tools; echo System disruption utilities; read'"
Categories=X-Kali-14-Impact;14-01-dos-tools;
EODESKTOP
fi

# Rebuild all databases
echo "Rebuilding menu databases..."
update-desktop-database -v /usr/share/applications
update-mime-database /usr/share/mime  
update-menus
gtk-update-icon-cache -f /usr/share/icons/hicolor 2>/dev/null || true

# Clear all caches
echo "Clearing menu caches..."
rm -rf /root/.cache/menus/*
rm -rf /home/kali/.cache/menus/*
rm -rf /root/.cache/xfce4/*
rm -rf /home/kali/.cache/xfce4/*

# Configure Whisker menu
echo "Configuring Whisker menu..."
mkdir -p /root/.config/xfce4/panel
cat > /root/.config/xfce4/panel/whiskermenu-1.rc <<'EOWHISKER'
favorites=xfce4-terminal.desktop,firefox-esr.desktop,kali-burpsuite.desktop,kali-metasploit-framework.desktop
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
EOWHISKER

# Force panel restart
echo "Restarting panel..."
if pgrep xfce4-panel > /dev/null; then
    xfce4-panel -r
else
    echo "Panel not running. Start desktop first."
fi

echo "Done! Whisker menu should now show all Kali categories."
echo ""
echo "Categories should include:"
echo "  01 - Information Gathering"
echo "  02 - Vulnerability Analysis" 
echo "  03 - Web Application Analysis"
echo "  04 - Database Assessment"
echo "  05 - Password Attacks"
echo "  06 - Wireless Attacks"
echo "  07 - Reverse Engineering"
echo "  08 - Exploitation Tools"
echo "  09 - Sniffing & Spoofing"
echo "  10 - Post Exploitation"
echo "  11 - Forensics"
echo "  12 - Reporting Tools"
echo "  13 - Social Engineering"
echo "  14 - System Services"
echo "  15 - Hardware Hacking"
EOF

echo ""
echo "Whisker menu fix complete!"
echo "If the menu doesn't update immediately, try:"
echo "  1. Right-click on panel → Panel → Restart"
echo "  2. Or close and reopen the desktop"