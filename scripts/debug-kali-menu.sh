#!/bin/bash
# Debug Kali menu issues

echo "Debugging Kali Menu Configuration"
echo "================================="

docker exec kali-workspace bash << 'EOF'
echo "1. Checking if kali-menu packages are installed:"
dpkg -l | grep -E "kali-menu|kali-desktop|kali-themes" | grep "^ii"

echo -e "\n2. Checking for Kali menu files:"
ls -la /etc/xdg/menus/kali-* 2>/dev/null || echo "No Kali menu files found in /etc/xdg/menus/"

echo -e "\n3. Checking XFCE menu configuration:"
ls -la /etc/xdg/menus/xfce-applications.menu 2>/dev/null || echo "No xfce-applications.menu"
if [ -L /etc/xdg/menus/xfce-applications.menu ]; then
    echo "xfce-applications.menu is a symlink to: $(readlink -f /etc/xdg/menus/xfce-applications.menu)"
fi

echo -e "\n4. Checking user menu configuration:"
ls -la /root/.config/menus/ 2>/dev/null || echo "No user menu config"

echo -e "\n5. Checking for Kali desktop directories:"
ls -la /usr/share/desktop-directories/kali-*.directory 2>/dev/null | head -10 || echo "No Kali desktop directories found"

echo -e "\n6. Checking for Kali-categorized applications:"
grep -l "X-Kali-" /usr/share/applications/*.desktop 2>/dev/null | wc -l
echo "Total applications with X-Kali categories: $(grep -l "X-Kali-" /usr/share/applications/*.desktop 2>/dev/null | wc -l)"

echo -e "\n7. Sample of installed Kali tools:"
ls /usr/share/applications/kali-*.desktop 2>/dev/null | head -5 || echo "No kali-*.desktop files found"

echo -e "\n8. Checking whisker menu plugin:"
ls -la /usr/lib/x86_64-linux-gnu/xfce4/panel/plugins/libwhiskermenu.so 2>/dev/null || echo "Whisker menu plugin not found"

echo -e "\n9. Current panel configuration:"
if [ -f /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml ]; then
    grep -A2 "whiskermenu" /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
else
    echo "No panel configuration found"
fi

echo -e "\n10. Checking if running as root:"
whoami

echo -e "\n11. Menu file content check:"
if [ -f /etc/xdg/menus/kali-applications.menu ]; then
    echo "First 20 lines of kali-applications.menu:"
    head -20 /etc/xdg/menus/kali-applications.menu
else
    echo "kali-applications.menu not found!"
fi
EOF

echo -e "\nDiagnostics complete!"