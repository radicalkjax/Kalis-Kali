#!/bin/bash
# Test script to debug kali-menu installation

echo "Testing kali-menu installation..."

docker exec -u root kali-workspace bash << 'EOF'
echo "=== Initial state ==="
dpkg -l | grep -E "kali-menu|kali-desktop-xfce|kali-linux-default" || echo "No kali packages found"

echo -e "\n=== Installing kali-menu ==="
apt-get update -qq
apt-get install -y kali-menu
echo "Exit code: $?"

echo -e "\n=== After kali-menu install ==="
dpkg -l | grep kali-menu

echo -e "\n=== Installing xfce4 packages with --no-install-recommends ==="
apt-get install -y --no-install-recommends \
    xfce4-session \
    xfce4-panel \
    xfce4-terminal \
    xfdesktop4 \
    xfwm4 \
    xfce4-settings \
    xfce4-whiskermenu-plugin
echo "Exit code: $?"

echo -e "\n=== After XFCE install ==="
dpkg -l | grep kali-menu || echo "kali-menu is NOT installed anymore!"

echo -e "\n=== Installing kali-desktop-xfce ==="
apt-get install -y kali-desktop-xfce
echo "Exit code: $?"

echo -e "\n=== After kali-desktop-xfce ==="
dpkg -l | grep kali-menu || echo "kali-menu is NOT installed anymore!"

echo -e "\n=== Checking for conflicts ==="
apt-cache depends kali-menu | grep Conflicts
apt-cache rdepends kali-menu | head -20

echo -e "\n=== Checking what provides xfce-applications.menu ==="
dpkg -S /etc/xdg/menus/xfce-applications.menu || echo "File not tracked"
EOF