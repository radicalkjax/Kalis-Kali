#!/bin/bash
# Test current menu state in container

echo "=== Current Menu System State ==="

docker exec -u root kali-workspace bash << 'EOF'
echo "1. Menu files in /etc/xdg/menus/:"
ls -la /etc/xdg/menus/

echo -e "\n2. Applications-merged contents:"
ls -la /etc/xdg/menus/applications-merged/ 2>/dev/null || echo "No applications-merged directory"

echo -e "\n3. Kali menu package status:"
dpkg -l | grep -E "kali-menu|kali-desktop" | head -10

echo -e "\n4. Desktop directories with 'kali':"
ls /usr/share/desktop-directories/ | grep -i kali | wc -l
echo "Total Kali desktop directories: $(ls /usr/share/desktop-directories/ | grep -i kali | wc -l)"

echo -e "\n5. Sample Kali desktop directories:"
ls /usr/share/desktop-directories/ | grep -i kali | head -10

echo -e "\n6. Check for numbered categories:"
ls /usr/share/desktop-directories/ | grep -E "kali-[0-9]" || echo "No numbered categories found"

echo -e "\n7. Applications with Kali categories:"
grep -l "Categories=.*[Kk]ali" /usr/share/applications/*.desktop 2>/dev/null | wc -l
echo "Total apps with Kali categories: $(grep -l "Categories=.*[Kk]ali" /usr/share/applications/*.desktop 2>/dev/null | wc -l)"

echo -e "\n8. Check what categories are actually used:"
grep "Categories=" /usr/share/applications/kali-*.desktop 2>/dev/null | sed 's/.*Categories=//' | sort -u | head -10

echo -e "\n9. Current xfce-applications.menu first 50 lines:"
head -50 /etc/xdg/menus/xfce-applications.menu 2>/dev/null || echo "File not found"
EOF