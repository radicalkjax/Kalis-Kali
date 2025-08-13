#!/bin/bash

# Ensure Kali Tools Script
# Installs Kali tool packages to populate menu categories

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

print_msg "Checking Kali Tools Installation"
echo "================================="

# Check if any kali-tools packages are installed
INSTALLED_COUNT=$(dpkg -l | grep -E '^ii.*kali-tools' | wc -l)

if [ "$INSTALLED_COUNT" -eq 0 ]; then
    print_warning "No Kali tools packages found"
    print_msg "Installing essential Kali tools for menu categories..."
    
    # Essential tool packages for malware analysis and forensics
    TOOL_PACKAGES=(
        "kali-tools-forensics"
        "kali-tools-reverse-engineering"
        "kali-tools-information-gathering"
        "kali-tools-exploitation"
        "kali-tools-post-exploitation"
        "kali-tools-reporting"
        "kali-tools-crypto-stego"
    )
    
    # Update package list quietly
    print_info "Updating package list..."
    apt-get update -qq
    
    # Install packages
    for package in "${TOOL_PACKAGES[@]}"; do
        print_info "Installing $package..."
        apt-get install -y --no-install-recommends "$package" >/dev/null 2>&1 || {
            print_warning "Failed to install $package, continuing..."
        }
    done
    
    print_msg "Kali tools installation complete"
else
    print_msg "Found $INSTALLED_COUNT Kali tool packages already installed"
fi

# Update menu database
print_info "Updating menu database..."
if [ -x /usr/share/kali-menu/update-kali-menu ]; then
    /usr/share/kali-menu/update-kali-menu 2>/dev/null || true
fi

update-desktop-database /usr/share/applications 2>/dev/null || true
xdg-desktop-menu forceupdate 2>/dev/null || true

print_msg "Kali tools check complete"