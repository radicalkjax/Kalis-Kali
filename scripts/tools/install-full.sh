#!/bin/bash

# Full Kali Tools Installation Script
# Installs all Kali metapackages for complete toolset

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_msg() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_error() {
    echo -e "${RED}[!]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[*]${NC} $1"
}

print_msg "Installing Full Kali Linux Toolset"
echo "=================================="
print_warning "This will install ALL Kali tools (several GB)"
echo ""

# Prompt for confirmation
read -p "Continue with full installation? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_msg "Installation cancelled"
    exit 0
fi

# Update package lists
print_msg "Updating package lists..."
apt-get update

# Kali metapackages in order of importance
METAPACKAGES=(
    # Core
    kali-linux-core
    kali-linux-headless
    kali-linux-default
    
    # Tool Categories
    kali-tools-top10
    kali-tools-web
    kali-tools-database
    kali-tools-passwords
    kali-tools-wireless
    kali-tools-reverse-engineering
    kali-tools-exploitation
    kali-tools-social-engineering
    kali-tools-sniffing-spoofing
    kali-tools-post-exploitation
    kali-tools-forensics
    kali-tools-reporting
    kali-tools-vulnerability
    kali-tools-information-gathering
    kali-tools-crypto-stego
    kali-tools-fuzzing
    kali-tools-802-11
    kali-tools-bluetooth
    kali-tools-rfid
    kali-tools-sdr
    kali-tools-voip
    kali-tools-windows-resources
    
    # Desktop (if GUI needed)
    kali-desktop-xfce
)

# Track installation progress
total=${#METAPACKAGES[@]}
current=0
failed_packages=()

print_msg "Starting installation of $total metapackages..."
echo ""

for package in "${METAPACKAGES[@]}"; do
    current=$((current + 1))
    echo "[$current/$total] Installing $package..."
    
    if dpkg -l | grep -q "^ii  $package"; then
        print_msg "  Already installed"
    else
        if apt-get install -y $package; then
            print_msg "  Successfully installed"
        else
            print_error "  Failed to install"
            failed_packages+=("$package")
        fi
    fi
    echo ""
done

# Install additional useful tools not in metapackages
print_msg "Installing additional tools..."
EXTRA_TOOLS=(
    # Additional RE tools
    ghidra
    rizin
    cutter
    radare2
    
    # Additional forensics
    autopsy
    sleuthkit
    volatility3
    
    # Network analysis
    mitmproxy
    bettercap
    
    # Development
    golang
    nodejs
    npm
    python3-venv
    
    # Utilities
    jq
    yq
    ripgrep
    fzf
    bat
    htop
    ncdu
)

for tool in "${EXTRA_TOOLS[@]}"; do
    echo -n "Installing $tool... "
    if apt-get install -y $tool >/dev/null 2>&1; then
        echo "done"
    else
        echo "skipped"
    fi
done

# Clean up
print_msg "Cleaning up package cache..."
apt-get autoremove -y >/dev/null 2>&1
apt-get clean

# Report results
echo ""
echo "======================================"
print_msg "Installation Summary"
echo "======================================"

if [ ${#failed_packages[@]} -eq 0 ]; then
    print_msg "✓ All metapackages installed successfully!"
else
    print_warning "The following packages failed to install:"
    for pkg in "${failed_packages[@]}"; do
        echo "  - $pkg"
    done
    echo ""
    print_msg "You can try installing them individually with:"
    echo "  apt-get install [package-name]"
fi

# Check disk usage
echo ""
print_msg "Disk Usage:"
df -h / | grep -E "^/|Filesystem"

echo ""
print_msg "Full Kali toolset installation complete!"
print_msg "Run 'apt list --installed | grep kali-' to see all installed Kali packages"