#!/bin/bash
# Fix Kali application menu entries in XFCE

echo "Fixing Kali Application Menu Entries"
echo "===================================="

# Check if container is running
if ! docker ps | grep -q kali-workspace; then
    echo "Error: kali-workspace container is not running"
    echo "Start it with: docker-compose up -d kali"
    exit 1
fi

# Fix application menu entries
docker exec -u root kali-workspace bash -c '
    echo "Installing menu packages..."
    apt-get update > /dev/null 2>&1
    apt-get install -y --no-install-recommends \
        kali-menu \
        xdg-utils \
        desktop-file-utils \
        shared-mime-info \
        hicolor-icon-theme \
        gnome-icon-theme \
        > /dev/null 2>&1

    echo "Updating desktop database..."
    update-desktop-database /usr/share/applications 2>/dev/null || true
    
    echo "Updating MIME database..."
    update-mime-database /usr/share/mime 2>/dev/null || true
    
    echo "Updating icon cache..."
    gtk-update-icon-cache -f /usr/share/icons/hicolor 2>/dev/null || true
    gtk-update-icon-cache -f /usr/share/icons/gnome 2>/dev/null || true
    
    echo "Rebuilding menu cache..."
    rm -rf /home/kali/.cache/menus/* 2>/dev/null || true
    rm -rf /home/kali/.config/menus/* 2>/dev/null || true
    
    # Ensure XDG directories exist
    mkdir -p /home/kali/.local/share/applications
    mkdir -p /home/kali/.config/menus
    
    # Set proper permissions
    chown -R kali:kali /home/kali/.cache 2>/dev/null || true
    chown -R kali:kali /home/kali/.config 2>/dev/null || true
    chown -R kali:kali /home/kali/.local 2>/dev/null || true
    
    # Force xfce4 to rebuild its menu
    su - kali -c "xfce4-panel --restart" 2>/dev/null || true
'

echo ""
echo "Menu fix completed!"
echo ""
echo "If the menu is still not showing all applications:"
echo "1. Right-click on the Applications menu"
echo "2. Select 'Properties'"
echo "3. Toggle 'Show generic application names' off and on"
echo "4. Or restart the desktop with: ./scripts/kali-desktop.sh"
echo ""
echo "The Applications menu should now show all Kali tools organized by category."