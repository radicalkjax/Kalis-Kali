#!/bin/bash

echo "[*] Kali Linux Container Setup Script"
echo "[*] Installing additional security tools..."

apt-get update

TOOLS=(
    "metasploit-framework"
    "burpsuite"
    "zaproxy"
    "sqlmap"
    "john"
    "hashcat"
    "hydra"
    "aircrack-ng"
    "recon-ng"
    "gobuster"
    "ffuf"
    "dirbuster"
    "nikto"
    "wpscan"
    "enum4linux"
    "smbclient"
    "evil-winrm"
    "chisel"
    "proxychains"
    "tor"
    "torsocks"
    "steghide"
    "binwalk"
    "foremost"
    "volatility3"
    "ghidra"
    "radare2"
    "gdb"
    "pwntools"
    "ropper"
    "checksec"
)

for tool in "${TOOLS[@]}"; do
    echo "[*] Installing $tool..."
    apt-get install -y "$tool" 2>/dev/null || echo "[-] Failed to install $tool"
done

echo "[*] Installing Python tools..."
pip3 install --upgrade pip
pip3 install pwntools ropper capstone unicorn keystone-engine

echo "[*] Installing Go tools..."
go install github.com/OJ/gobuster/v3@latest
go install github.com/ffuf/ffuf@latest
go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

echo "[*] Setting up Metasploit database..."
systemctl start postgresql
msfdb init

echo "[*] Setup complete!"