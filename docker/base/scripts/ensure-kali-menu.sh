#!/bin/bash
# Ensure Kali menu is available on container startup

# Check if kali-menu is installed
if ! dpkg -l | grep -q "^ii  kali-menu "; then
    echo "WARNING: kali-menu is not installed in the container!"
    echo "Installing kali-menu and dependencies..."
    
    apt-get update
    apt-get install -y \
        kali-menu \
        kali-desktop-xfce \
        kali-themes \
        kali-defaults \
        xfce4-whiskermenu-plugin \
        menu \
        menu-xdg \
        garcon
    
    # Run update-kali-menu if available
    if [ -x /usr/share/kali-menu/update-kali-menu ]; then
        /usr/share/kali-menu/update-kali-menu
    fi
    
    # Update desktop database
    update-desktop-database /usr/share/applications
fi

# Ensure applications-merged directory exists
mkdir -p /etc/xdg/menus/applications-merged

# Check if Kali menu structure is present
if [ ! -f /etc/xdg/menus/applications-merged/kali-applications.menu ] && \
   [ -f /usr/share/kali-menu/etc/xdg/menus/applications-merged/kali-applications.menu ]; then
    echo "Copying Kali menu structure..."
    cp -r /usr/share/kali-menu/etc/xdg/menus/* /etc/xdg/menus/
fi

echo "Kali menu check complete"