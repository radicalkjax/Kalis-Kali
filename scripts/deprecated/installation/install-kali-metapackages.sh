#!/bin/bash
# Script to install Kali metapackages in the Docker container
# This can be run to pre-install packages or debug installation issues

echo "Kali Metapackage Installer"
echo "=========================="
echo ""
echo "This script will install the 16 Kali tool category metapackages."
echo "Each package contains many tools and can take several minutes to install."
echo ""

# Check if running in Docker
if [ ! -f /.dockerenv ]; then
    echo "This script should be run inside the Docker container."
    echo "Run: docker exec -it -u root kali-workspace bash"
    echo "Then: /path/to/this/script.sh"
    exit 1
fi

# Ensure we're running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo or docker exec -u root)"
    exit 1
fi

# Update package lists
echo "Updating package lists..."
apt-get update

# List of metapackages
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

# Show what will be installed
echo ""
echo "The following metapackages will be installed:"
for i in "${!PACKAGES[@]}"; do
    printf "%2d. %s\n" $((i+1)) "${PACKAGES[$i]}"
done

echo ""
read -p "Do you want to proceed? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

# Install packages with progress tracking
TOTAL=${#PACKAGES[@]}
INSTALLED=0
FAILED=0
FAILED_PACKAGES=()

for i in "${!PACKAGES[@]}"; do
    package="${PACKAGES[$i]}"
    echo ""
    echo "=========================================="
    echo "[$((i+1))/$TOTAL] Installing: $package"
    echo "=========================================="
    
    # Show package info
    echo "Checking package size..."
    apt-cache show "$package" 2>/dev/null | grep -E "^(Size|Installed-Size):" || true
    
    # Install with timeout
    if timeout 900 apt-get install -y --no-install-recommends "$package"; then
        echo "✓ Successfully installed $package"
        ((INSTALLED++))
    else
        echo "✗ Failed to install $package"
        ((FAILED++))
        FAILED_PACKAGES+=("$package")
    fi
    
    # Show progress
    echo ""
    echo "Progress: $INSTALLED installed, $FAILED failed, $((TOTAL - i - 1)) remaining"
done

# Summary
echo ""
echo "=========================================="
echo "Installation Summary"
echo "=========================================="
echo "Total packages: $TOTAL"
echo "Successfully installed: $INSTALLED"
echo "Failed: $FAILED"

if [ $FAILED -gt 0 ]; then
    echo ""
    echo "Failed packages:"
    for package in "${FAILED_PACKAGES[@]}"; do
        echo "  - $package"
    done
    echo ""
    echo "You can try installing failed packages individually with:"
    echo "  apt-get install -y --no-install-recommends <package-name>"
fi

# Update menu databases
echo ""
echo "Updating menu databases..."
update-desktop-database /usr/share/applications
update-menus

echo ""
echo "Installation complete!"