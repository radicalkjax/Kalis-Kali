#!/bin/bash
# Directly install and configure Applications Menu

echo "Installing Proper Applications Menu"
echo "==================================="

# Check if container is running
if ! docker ps | grep -q kali-workspace; then
    echo "Error: kali-workspace container is not running"
    echo "Start it with: docker-compose up -d kali"
    exit 1
fi

docker exec kali-workspace bash -c '
    # Kill current panel
    pkill xfce4-panel
    
    # Remove old configs
    rm -rf /root/.config/xfce4/panel
    rm -rf /root/.cache/sessions/xfce4-panel*
    
    # Create fresh panel config directory
    mkdir -p /root/.config/xfce4/panel
    
    # Start panel with default config
    DISPLAY=host.docker.internal:0 xfce4-panel --disable-wm-check &
    sleep 5
    
    # Use xfce4-panel to add applications menu
    DISPLAY=host.docker.internal:0 xfce4-panel --add=applicationsmenu
    
    echo "Panel restarted with Applications Menu"
'

echo ""
echo "Applications Menu installed!"
echo ""
echo "The panel should now have the Applications Menu."
echo "If it still shows directories, you need to manually configure it:"
echo ""
echo "1. Right-click on the blue folder icon"
echo "2. If you see 'Properties', click it"
echo "3. Make sure it says 'Applications Menu' not 'Directory Menu'"
echo ""
echo "OR"
echo ""
echo "1. Right-click on empty space in the panel"
echo "2. Select 'Panel > Panel Preferences'"
echo "3. Go to the 'Items' tab"
echo "4. Look for the menu item - it should say 'Applications Menu'"
echo "5. If it says 'Directory Menu', remove it and add 'Applications Menu' instead"