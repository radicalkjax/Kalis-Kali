#!/bin/bash
# Setup Whisker Menu with proper Kali categories

echo "Setting up Whisker Menu for Better Application Organization"
echo "=========================================================="

# Check if container is running
if ! docker ps | grep -q kali-workspace; then
    echo "Error: kali-workspace container is not running"
    echo "Start it with: docker-compose up -d kali"
    exit 1
fi

docker exec kali-workspace bash -c '
    echo "Installing Whisker Menu..."
    apt-get update >/dev/null 2>&1
    apt-get install -y xfce4-whiskermenu-plugin >/dev/null 2>&1
    
    echo "Configuring Whisker Menu..."
    mkdir -p /root/.config/xfce4/panel
    
    # Create whisker menu configuration
    cat > /root/.config/xfce4/panel/whiskermenu-1.rc <<EOF
favorites=firefox-esr.desktop,xfce4-terminal.desktop,kali-burpsuite.desktop,kali-metasploit-framework.desktop,kali-nmap.desktop
recent=
button-icon=kali-menu
button-single-row=false
show-button-title=false
show-button-icon=true
launcher-show-name=true
launcher-show-description=true
launcher-show-tooltip=true
launcher-icon-size=2
hover-switch-category=false
category-icon-size=1
load-hierarchy=true
view-as-icons=false
default-category=0
recent-items-max=10
favorites-in-recent=true
position-search-alternate=true
position-commands-alternate=false
position-categories-alternate=true
position-categories-horizontal=false
stay-on-focus-out=false
profile-shape=0
confirm-session-command=true
menu-width=450
menu-height=500
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
    
    echo "Adding Whisker Menu to panel..."
    # This will add whisker menu but might need manual configuration
    xfce4-panel --add=whiskermenu >/dev/null 2>&1 || true
'

echo ""
echo "Whisker Menu setup complete!"
echo ""
echo "To use the Whisker Menu instead of the default Applications Menu:"
echo "1. Right-click on the panel"
echo "2. Select 'Panel > Panel Preferences'"
echo "3. Go to the 'Items' tab"
echo "4. Find 'Applications Menu' and remove it"
echo "5. Click '+' to add a new item"
echo "6. Select 'Whisker Menu' and add it"
echo "7. Move it to your preferred position"
echo ""
echo "The Whisker Menu provides better organization and search functionality!"