#!/bin/bash

# Core Kali Tools Installation Script
# Installs essential security tools only

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

print_msg "Installing Core Kali Tools"
echo "=========================="

# Update package lists
print_msg "Updating package lists..."
apt-get update

# Core security tools
CORE_TOOLS=(
    # Network Tools
    nmap
    netcat-openbsd
    tcpdump
    wireshark
    tshark
    arp-scan
    
    # Web Tools
    burpsuite
    sqlmap
    gobuster
    ffuf
    nikto
    wpscan
    
    # Exploitation
    metasploit-framework
    searchsploit
    exploitdb
    
    # Password Tools
    john
    hashcat
    hydra
    medusa
    
    # Wireless
    aircrack-ng
    kismet
    reaver
    
    # Information Gathering
    whois
    dnsutils
    fierce
    theharvester
    
    # Utilities
    git
    curl
    wget
    vim
    tmux
    python3-pip
)

# Install tools
total=${#CORE_TOOLS[@]}
current=0

for tool in "${CORE_TOOLS[@]}"; do
    current=$((current + 1))
    echo -n "[$current/$total] Installing $tool... "
    
    if dpkg -l | grep -q "^ii  $tool"; then
        echo "already installed"
    else
        if apt-get install -y $tool >/dev/null 2>&1; then
            echo "done"
        else
            echo "failed (skipping)"
        fi
    fi
done

# Install Python tools via pip
print_msg "Installing Python-based tools..."
pip3 install --break-system-packages \
    impacket \
    scapy \
    pwntools \
    requests \
    beautifulsoup4 \
    2>/dev/null || print_warning "Some Python packages failed to install"

# Verify installations
print_msg "Verifying installations..."
echo ""
echo "Core Tools Status:"
echo "=================="

# Check critical tools
critical_tools=(nmap burpsuite metasploit-framework sqlmap john aircrack-ng)
for tool in "${critical_tools[@]}"; do
    if command -v $tool >/dev/null 2>&1 || dpkg -l | grep -q "^ii  $tool"; then
        echo "✓ $tool"
    else
        echo "✗ $tool (not installed)"
    fi
done

print_msg "Core tools installation complete!"
echo ""
print_msg "To install ALL Kali tools, run:"
echo "  ./scripts/tools/install-full.sh"