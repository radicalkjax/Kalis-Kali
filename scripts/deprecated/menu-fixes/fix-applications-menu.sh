#!/bin/bash
# Fix XFCE Applications Menu to show all Kali tools in categories

echo "Fixing XFCE Applications Menu Categories"
echo "======================================="

# Check if container is running
if ! docker ps | grep -q kali-workspace; then
    echo "Error: kali-workspace container is not running"
    echo "Start it with: docker-compose up -d kali"
    exit 1
fi

# Fix the Applications Menu
docker exec kali-workspace bash -c '
    echo "Installing required packages..."
    apt-get update >/dev/null 2>&1
    apt-get install -y \
        kali-menu \
        xfce4-whiskermenu-plugin \
        garcon \
        libgarcon-1-0 \
        libgarcon-common \
        xdg-utils \
        desktop-file-utils \
        2>/dev/null
    
    echo "Creating menu structure..."
    mkdir -p /root/.config/menus
    mkdir -p /root/.local/share/desktop-directories
    
    # Copy Kali menu structure
    if [ -f /etc/xdg/menus/kali-applications.menu ]; then
        cp /etc/xdg/menus/kali-applications.menu /root/.config/menus/xfce-applications.menu
    else
        # Create a basic menu structure if kali menu is missing
        cat > /root/.config/menus/xfce-applications.menu <<EOF
<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
 "http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">
<Menu>
  <Name>Xfce</Name>
  <DefaultAppDirs/>
  <DefaultDirectoryDirs/>
  <DefaultMergeDirs/>
  <Include>
    <All/>
  </Include>
  
  <!-- Kali Categories -->
  <Menu>
    <Name>01-info-gathering</Name>
    <Directory>kali-info-gathering.directory</Directory>
    <Include>
      <Category>01-info-gathering</Category>
    </Include>
  </Menu>
  
  <Menu>
    <Name>02-vulnerability-analysis</Name>
    <Directory>kali-vulnerability-analysis.directory</Directory>
    <Include>
      <Category>02-vulnerability-analysis</Category>
    </Include>
  </Menu>
  
  <Menu>
    <Name>03-webapp-analysis</Name>
    <Directory>kali-webapp-analysis.directory</Directory>
    <Include>
      <Category>03-webapp-analysis</Category>
    </Include>
  </Menu>
  
  <Menu>
    <Name>04-database-assessment</Name>
    <Directory>kali-database-assessment.directory</Directory>
    <Include>
      <Category>04-database-assessment</Category>
    </Include>
  </Menu>
  
  <Menu>
    <Name>05-password-attacks</Name>
    <Directory>kali-password-attacks.directory</Directory>
    <Include>
      <Category>05-password-attacks</Category>
    </Include>
  </Menu>
  
  <Menu>
    <Name>06-wireless-attacks</Name>
    <Directory>kali-wireless-attacks.directory</Directory>
    <Include>
      <Category>06-wireless-attacks</Category>
    </Include>
  </Menu>
  
  <Menu>
    <Name>07-reverse-engineering</Name>
    <Directory>kali-reverse-engineering.directory</Directory>
    <Include>
      <Category>07-reverse-engineering</Category>
    </Include>
  </Menu>
  
  <Menu>
    <Name>08-exploitation-tools</Name>
    <Directory>kali-exploitation-tools.directory</Directory>
    <Include>
      <Category>08-exploitation-tools</Category>
    </Include>
  </Menu>
  
  <Menu>
    <Name>09-sniffing-spoofing</Name>
    <Directory>kali-sniffing-spoofing.directory</Directory>
    <Include>
      <Category>09-sniffing-spoofing</Category>
    </Include>
  </Menu>
  
  <Menu>
    <Name>10-post-exploitation</Name>
    <Directory>kali-post-exploitation.directory</Directory>
    <Include>
      <Category>10-post-exploitation</Category>
    </Include>
  </Menu>
  
  <Menu>
    <Name>11-forensics</Name>
    <Directory>kali-forensics.directory</Directory>
    <Include>
      <Category>11-forensics</Category>
    </Include>
  </Menu>
  
  <Menu>
    <Name>12-reporting</Name>
    <Directory>kali-reporting.directory</Directory>
    <Include>
      <Category>12-reporting</Category>
    </Include>
  </Menu>
  
  <Menu>
    <Name>13-social-engineering</Name>
    <Directory>kali-social-engineering.directory</Directory>
    <Include>
      <Category>13-social-engineering</Category>
    </Include>
  </Menu>
</Menu>
EOF
    fi
    
    echo "Updating desktop database..."
    update-desktop-database /usr/share/applications
    
    echo "Clearing menu cache..."
    rm -rf /root/.cache/menus/*
    rm -rf /root/.cache/sessions/xfce4-panel*
    
    echo "Rebuilding menu..."
    xdg-desktop-menu forceupdate
    
    echo "Restarting panel to apply changes..."
    xfce4-panel --restart
'

echo ""
echo "Applications Menu fixed!"
echo ""
echo "The blue folder menu should now show:"
echo "- Information Gathering"
echo "- Vulnerability Analysis"
echo "- Web Application Analysis"
echo "- Database Assessment"
echo "- Password Attacks"
echo "- Wireless Attacks"
echo "- Reverse Engineering"
echo "- Exploitation Tools"
echo "- Sniffing & Spoofing"
echo "- Post Exploitation"
echo "- Forensics"
echo "- Reporting"
echo "- Social Engineering Tools"
echo ""
echo "If the menu doesn't update immediately:"
echo "1. Right-click on the Applications Menu"
echo "2. Select 'Properties'"
echo "3. Toggle 'Show button title' off and on"
echo "4. Or restart the panel with: docker exec kali-workspace xfce4-panel --restart"