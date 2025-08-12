#!/bin/bash
# Fix desktop menu for root user in container

echo "Fixing Desktop Menu for Root User"
echo "================================="

# Check if container is running
if ! docker ps | grep -q kali-workspace; then
    echo "Error: kali-workspace container is not running"
    echo "Start it with: docker-compose up -d kali"
    exit 1
fi

# Fix menus for root user
docker exec kali-workspace bash -c '
    echo "Installing menu packages..."
    apt-get update >/dev/null 2>&1
    apt-get install -y \
        kali-menu \
        kali-desktop-xfce \
        xdg-utils \
        desktop-file-utils \
        menu \
        menu-xdg \
        2>/dev/null
    
    echo "Creating root desktop directories..."
    mkdir -p /root/.config/menus
    mkdir -p /root/.local/share/applications
    mkdir -p /root/.cache/xfce4
    
    echo "Updating desktop database..."
    update-desktop-database -v /usr/share/applications
    
    echo "Updating menu cache..."
    update-menus
    
    echo "Clearing caches..."
    rm -rf /root/.cache/menus/* 2>/dev/null
    rm -rf /root/.cache/xfce4/desktop/* 2>/dev/null
    rm -rf /root/.cache/xfce4/appfinder/* 2>/dev/null
    
    echo "Forcing XDG menu update..."
    XDG_CONFIG_HOME=/root/.config XDG_DATA_HOME=/root/.local/share xdg-desktop-menu forceupdate
    
    echo "Restarting menu components..."
    pkill -HUP xfce4-panel 2>/dev/null || true
    pkill xfce4-appfinder 2>/dev/null || true
'

echo ""
echo "Desktop menu fixed for root user!"
echo ""
echo "To launch Application Finder with all Kali tools:"
echo "docker exec -e DISPLAY=host.docker.internal:0 kali-workspace xfce4-appfinder"