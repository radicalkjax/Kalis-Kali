#!/bin/bash
# Direct installation script for Kali tools

echo "Installing Kali Tools Metapackages"
echo "=================================="

# Ensure we're in the right directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Check if container is running
if ! docker ps | grep -q kali-workspace; then
    echo "Error: kali-workspace container is not running"
    exit 1
fi

# Update package lists
echo "Updating package lists..."
docker exec -u root kali-workspace apt-get update

# List of packages to install
PACKAGES=(
    "kali-tools-information-gathering"
    "kali-tools-vulnerability"
    "kali-tools-web"
    "kali-tools-database"
    "kali-tools-passwords"
    "kali-tools-wireless"
    "kali-tools-reverse-engineering"
    "kali-tools-exploitation"
    "kali-tools-sniffing-spoofing"
    "kali-tools-post-exploitation"
    "kali-tools-forensics"
    "kali-tools-reporting"
    "kali-tools-social-engineering"
    "kali-tools-hardware"
    "kali-tools-crypto-stego"
    "kali-tools-fuzzing"
)

# Install packages one by one
TOTAL=${#PACKAGES[@]}
for i in "${!PACKAGES[@]}"; do
    package="${PACKAGES[$i]}"
    echo ""
    echo "[$((i+1))/$TOTAL] Installing $package..."
    
    # Use direct docker exec instead of heredoc
    if docker exec -u root kali-workspace timeout 600 apt-get install -y --no-install-recommends "$package"; then
        echo "✓ Successfully installed $package"
    else
        echo "✗ Failed to install $package"
    fi
done

echo ""
echo "Installation complete!"

# Update menu databases
echo "Updating menu databases..."
docker exec -u root kali-workspace update-desktop-database /usr/share/applications
docker exec -u root kali-workspace update-menus

echo "Done!"