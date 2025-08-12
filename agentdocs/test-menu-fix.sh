#!/bin/bash
# Test if the menu fix works

echo "Testing Kali Menu Fix"
echo "===================="

# First install kali-menu
docker exec -u root kali-workspace bash << 'EOF'
echo "1. Installing kali-menu..."
apt-get update -qq
apt-get install -y kali-menu kali-desktop-xfce

echo -e "\n2. Checking installation:"
dpkg -l | grep "kali-menu"

echo -e "\n3. Checking menu files:"
ls -la /etc/xdg/menus/applications-merged/ 2>/dev/null || echo "No applications-merged"

echo -e "\n4. Running update-kali-menu if available:"
if [ -x /usr/share/kali-menu/update-kali-menu ]; then
    /usr/share/kali-menu/update-kali-menu
    echo "Update complete"
else
    echo "update-kali-menu not found"
fi

echo -e "\n5. Checking for Kali categories in applications:"
grep -l "Categories=.*X-Kali-" /usr/share/applications/*.desktop 2>/dev/null | wc -l
echo "Apps with X-Kali categories: $(grep -l "Categories=.*X-Kali-" /usr/share/applications/*.desktop 2>/dev/null | wc -l)"

grep -l "Categories=.*kali-" /usr/share/applications/*.desktop 2>/dev/null | wc -l  
echo "Apps with kali- categories: $(grep -l "Categories=.*kali-" /usr/share/applications/*.desktop 2>/dev/null | wc -l)"

echo -e "\n6. Sample categories:"
grep "Categories=" /usr/share/applications/kali-*.desktop 2>/dev/null | head -5
EOF