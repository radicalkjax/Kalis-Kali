# Kali Linux Container Tools Overview

This document outlines what tools are included in our custom Kali Linux container setup.

## Base Image: kalilinux/kali-rolling:latest

The official Kali rolling image provides a **minimal base installation** with:
- Core Linux utilities
- Package management (apt, dpkg)
- Basic shell environment
- NO pre-installed security tools

## Our Additions

### 1. Kali Metapackages

**kali-linux-core**
- Essential Kali system packages
- Basic networking tools
- Core utilities (sudo, openssh-server, etc.)

**kali-tools-top10**
- Metasploit Framework
- Nmap
- Wireshark
- Burp Suite
- John the Ripper
- Aircrack-ng
- SQLMap
- Hashcat
- Hydra
- And other top security tools

### 2. GUI Support (Not in base)
- XFCE4 desktop environment
- X11 forwarding support (XQuartz on macOS)
- Firefox ESR browser
- Native macOS window integration

### 3. Development Tools (Not in base)
- **Languages**: Go, Node.js, Python 3 with venv
- **Build tools**: build-essential, cmake, pkg-config
- **Libraries**: libssl-dev
- **Package managers**: npm, pip3

### 4. Shell Enhancements (Not in base)
- Zsh with Oh My Zsh
- tmux terminal multiplexer

### 5. Malware Analysis Tools (Specialized additions)

**Reverse Engineering**
- Ghidra - NSA's reverse engineering framework
- Rizin & Cutter - Radare2 fork with GUI
- EDB debugger - Linux debugger similar to OllyDbg

**Binary Analysis**
- hexedit - Hex editor
- xxd - Hex dump utility
- exiftool - Metadata extraction

**Dynamic Analysis**
- ltrace - Library call tracer
- gdbserver - Remote debugging
- valgrind - Memory debugging

**Windows Analysis**
- Wine (32/64 bit) - Windows compatibility layer
- Mono - .NET framework implementation

**Forensics**
- Volatility3 - Memory forensics
- Sleuthkit & Autopsy - Disk forensics
- foremost & scalpel - File carving

**Virtualization**
- QEMU - Full system emulation for sandboxing

**Python RE Libraries**
- pefile, pyelftools - Binary parsing
- capstone, keystone, unicorn - Assembly/emulation
- angr - Binary analysis framework
- z3-solver - Constraint solving

### 6. AI Integration
- Claude CLI - AI assistant for code and security tasks

## Python Packages (via pip)

### Core Analysis
- yara-python - Pattern matching
- oletools - MS Office document analysis
- androguard - Android APK analysis
- frida-tools - Dynamic instrumentation
- objection - Runtime mobile exploration

### Network & Crypto
- impacket - Network protocols
- scapy - Packet manipulation
- mitmproxy - HTTPS proxy
- dnspython - DNS toolkit
- cryptography - Crypto primitives

### Advanced RE
- angr - Symbolic execution
- miasm - Reverse engineering framework
- vivisect - Binary analysis framework
- capa - Capability detection
- flare-floss - String extraction

## Additional Resources

### Git Repositories Cloned
- FLARE FLOSS - Advanced string extraction
- XLMMacroDeobfuscator - Excel macro analysis
- Volatility3 - Latest memory forensics

### YARA Rules (via setup script)
- Yara-Rules/rules
- Neo23x0/signature-base
- bartblaze/Yara-rules
- elastic/protections-artifacts

## Network Isolation

The malware analysis container (`docker-compose.malware.yml`) runs with:
- `network_mode: none` - Complete network isolation
- Resource limits - 4GB RAM, 2 CPU cores
- No exposed ports - complete isolation

## Usage Notes

1. **Standard Container**: Full network access, general security testing
2. **Malware Container**: Isolated environment for malware analysis
3. **Persistent Storage**: 
   - `./workspace` - General work files
   - `./malware-samples` - Malware samples (read-only in container)
   - `./malware-reports` - Analysis reports