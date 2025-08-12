#!/bin/bash
# Rebuild XFCE application menu and finder database

echo "Rebuilding XFCE Application Menu Database"
echo "========================================"

# Check if container is running
if ! docker ps | grep -q kali-workspace; then
    echo "Error: kali-workspace container is not running"
    echo "Start it with: docker-compose up -d kali"
    exit 1
fi

# Rebuild application database
docker exec -u root kali-workspace bash -c '
    echo "Updating desktop file database..."
    update-desktop-database -v /usr/share/applications
    
    echo "Clearing XFCE caches..."
    rm -rf /home/kali/.cache/xfce4/desktop/*
    rm -rf /home/kali/.cache/menus/*
    rm -rf /home/kali/.cache/sessions/*
    
    echo "Rebuilding XFCE menu cache..."
    su - kali -c "
        # Force XFCE to rebuild its application database
        xfce4-appfinder --quit 2>/dev/null || true
        killall xfce4-appfinder 2>/dev/null || true
        
        # Clear appfinder cache
        rm -rf ~/.cache/xfce4/appfinder/*
        
        # Update XDG menu
        xdg-desktop-menu forceupdate
    "
    
    echo "Setting correct permissions..."
    chown -R kali:kali /home/kali/.cache
    chown -R kali:kali /home/kali/.config
'

echo ""
echo "Menu database rebuilt!"
echo ""
echo "Now restart the Application Finder to see all tools:"
echo "docker exec -it kali-workspace xfce4-appfinder"