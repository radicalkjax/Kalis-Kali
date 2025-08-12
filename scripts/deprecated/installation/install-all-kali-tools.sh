#!/bin/bash
# Install all Kali Linux tools in the container

echo "Installing All Kali Linux Tools"
echo "==============================="
echo "This will install several GB of tools and may take 30-60 minutes"
echo ""

# Check if container is running
if ! docker ps | grep -q kali-workspace; then
    echo "Error: kali-workspace container is not running"
    echo "Start it with: ./scripts/start-kali.sh"
    exit 1
fi

echo "Installing Kali Linux tool categories..."
echo ""

# Function to install a category and show progress
install_category() {
    local category=$1
    local description=$2
    echo -n "Installing $description... "
    if docker exec kali-workspace sh -c "apt-get install -y $category > /dev/null 2>&1"; then
        echo "✓"
    else
        echo "⚠️  (some packages may have failed)"
    fi
}

# Update package lists first
echo -n "Updating package lists... "
docker exec kali-workspace apt-get update > /dev/null 2>&1
echo "✓"

# Core metapackages
echo ""
echo "Installing Core Metapackages:"
echo "----------------------------"
install_category "kali-linux-default" "Default Kali Linux tools"
install_category "kali-linux-large" "Large collection of tools"
install_category "kali-linux-everything" "ALL Kali Linux tools (this is huge!)"

# Tool categories
echo ""
echo "Installing Tool Categories:"
echo "--------------------------"
install_category "kali-tools-information-gathering" "Information Gathering tools"
install_category "kali-tools-vulnerability" "Vulnerability Analysis tools"
install_category "kali-tools-web" "Web Application Analysis tools"
install_category "kali-tools-database" "Database Assessment tools"
install_category "kali-tools-passwords" "Password Attacks tools"
install_category "kali-tools-wireless" "Wireless Attacks tools"
install_category "kali-tools-reverse-engineering" "Reverse Engineering tools"
install_category "kali-tools-exploitation" "Exploitation Tools"
install_category "kali-tools-social-engineering" "Social Engineering tools"
install_category "kali-tools-sniffing-spoofing" "Sniffing & Spoofing tools"
install_category "kali-tools-post-exploitation" "Post Exploitation tools"
install_category "kali-tools-forensics" "Forensics tools"
install_category "kali-tools-reporting" "Reporting Tools"
install_category "kali-tools-gpu" "GPU Tools"
install_category "kali-tools-hardware" "Hardware Hacking tools"
install_category "kali-tools-crypto-stego" "Crypto & Stego tools"
install_category "kali-tools-fuzzing" "Fuzzing Tools"
install_category "kali-tools-802-11" "802.11 Wireless tools"
install_category "kali-tools-bluetooth" "Bluetooth tools"
install_category "kali-tools-rfid" "RFID/NFC tools"
install_category "kali-tools-sdr" "Software Defined Radio tools"
install_category "kali-tools-voip" "VoIP tools"
install_category "kali-tools-windows-resources" "Windows Resources"

# Additional useful tools not in metapackages
echo ""
echo "Installing Additional Tools:"
echo "---------------------------"
docker exec kali-workspace sh -c "apt-get install -y \
    bloodhound \
    covenant \
    evil-winrm \
    gobuster \
    seclists \
    payloadsallthethings \
    dirsearch \
    ffuf \
    feroxbuster \
    kerbrute \
    ligolo-ng \
    chisel \
    proxychains4 \
    socat \
    rlwrap \
    powershell \
    neo4j \
    bloodhound-python \
    certipy-ad \
    crackmapexec \
    enum4linux-ng \
    impacket-scripts \
    nbtscan \
    onesixtyone \
    oscanner \
    redis-tools \
    sipvicious \
    snmpcheck \
    sparta \
    sslscan \
    sslyze \
    thc-ipv6 \
    thc-ssl-dos \
    theharvester \
    fierce \
    dnsrecon \
    dnsenum \
    sublist3r \
    amass \
    spiderfoot \
    maltego \
    shodan \
    whatweb \
    arjun \
    wpscan \
    joomscan \
    droopescan \
    nuclei \
    subfinder \
    httpx-toolkit \
    > /dev/null 2>&1" && echo "✓ Additional tools installed"

# Clean up
echo ""
echo -n "Cleaning up package cache... "
docker exec kali-workspace sh -c "apt-get clean && rm -rf /var/lib/apt/lists/*" > /dev/null 2>&1
echo "✓"

echo ""
echo "Installation complete!"
echo ""
echo "To see all installed tools:"
echo "  docker exec kali-workspace dpkg -l | grep -E 'kali-|metasploit|nmap|burp|wireshark'"
echo ""
echo "To launch GUI and access tools:"
echo "  ./scripts/kali-desktop.sh"
echo ""
echo "Popular tools now available:"
echo "  - Metasploit Framework"
echo "  - Burp Suite"
echo "  - Nmap"
echo "  - Wireshark"
echo "  - John the Ripper"
echo "  - Hashcat"
echo "  - Aircrack-ng"
echo "  - SQLmap"
echo "  - Nikto"
echo "  - Dirb/Dirbuster"
echo "  - Hydra"
echo "  - And hundreds more!"