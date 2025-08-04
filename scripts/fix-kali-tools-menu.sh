#!/bin/bash
# Fix Kali tools installation and menu entries

echo "Fixing Kali Tools and Application Menu"
echo "======================================"

# Check if container is running
if ! docker ps | grep -q kali-workspace; then
    echo "Error: kali-workspace container is not running"
    echo "Start it with: docker-compose up -d kali"
    exit 1
fi

# Install missing tools and fix menus
docker exec -u root kali-workspace bash -c '
    echo "Updating package list..."
    apt-get update
    
    echo "Installing Burp Suite and other common tools that might be missing..."
    apt-get install -y \
        burpsuite \
        zaproxy \
        metasploit-framework \
        nmap \
        wireshark \
        john \
        hashcat \
        sqlmap \
        dirb \
        gobuster \
        hydra \
        nikto \
        wpscan \
        aircrack-ng \
        recon-ng \
        theharvester \
        maltego \
        set \
        beef-xss \
        2>/dev/null || true
    
    echo "Installing menu and desktop integration packages..."
    apt-get install -y \
        kali-menu \
        kali-desktop-xfce \
        xdg-utils \
        desktop-file-utils \
        shared-mime-info \
        hicolor-icon-theme \
        gnome-icon-theme \
        menu \
        menu-xdg \
        2>/dev/null || true
    
    echo "Rebuilding desktop database..."
    update-desktop-database -v /usr/share/applications
    
    echo "Updating MIME database..."
    update-mime-database /usr/share/mime
    
    echo "Updating icon caches..."
    for theme in /usr/share/icons/*; do
        if [ -d "$theme" ]; then
            gtk-update-icon-cache -f "$theme" 2>/dev/null || true
        fi
    done
    
    echo "Updating menu cache..."
    update-menus
    
    echo "Clearing user menu cache..."
    rm -rf /home/kali/.cache/menus/*
    rm -rf /home/kali/.config/menus/*
    rm -rf /home/kali/.cache/xfce4/desktop/*
    
    echo "Creating menu directories..."
    mkdir -p /home/kali/.local/share/applications
    mkdir -p /home/kali/.config/menus
    mkdir -p /home/kali/.config/xfce4/desktop
    
    echo "Setting permissions..."
    chown -R kali:kali /home/kali/.cache
    chown -R kali:kali /home/kali/.config
    chown -R kali:kali /home/kali/.local
    
    echo "Generating XDG menu..."
    su - kali -c "xdg-desktop-menu forceupdate" 2>/dev/null || true
    
    echo "Restarting menu services..."
    pkill -HUP xfce4-panel 2>/dev/null || true
    pkill -HUP xfdesktop 2>/dev/null || true
'

echo ""
echo "Checking installed tools..."
docker exec kali-workspace bash -c '
    echo ""
    echo "Verifying key tools:"
    echo -n "Burp Suite: "; which burpsuite >/dev/null 2>&1 && echo "✓ Installed" || echo "✗ Not found"
    echo -n "Metasploit: "; which msfconsole >/dev/null 2>&1 && echo "✓ Installed" || echo "✗ Not found"
    echo -n "Nmap: "; which nmap >/dev/null 2>&1 && echo "✓ Installed" || echo "✗ Not found"
    echo -n "Wireshark: "; which wireshark >/dev/null 2>&1 && echo "✓ Installed" || echo "✗ Not found"
    echo -n "SQLMap: "; which sqlmap >/dev/null 2>&1 && echo "✓ Installed" || echo "✗ Not found"
    echo ""
'

echo ""
echo "Menu fix completed!"
echo ""
echo "To see the changes:"
echo "1. If desktop is running, right-click on the panel"
echo "2. Select 'Panel > Panel Preferences'"
echo "3. Go to 'Items' tab"
echo "4. Select 'Applications Menu' and click the gear icon"
echo "5. Make sure 'Show button title' is checked"
echo ""
echo "Or restart the desktop with: ./scripts/kali-desktop.sh"
echo ""
echo "You can also search for applications by running:"
echo "docker exec -it kali-workspace xfce4-appfinder"