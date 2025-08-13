# Kali Linux Docker Desktop Environment

**Version:** 0.5-alpha  
**Last Updated:** August 2024  
**Status:** ⚠️ Partially Working - Active Development

A fully-featured Kali Linux desktop environment running in Docker with seamless macOS integration via XQuartz. Features a vertical panel with quick-launch tools, comprehensive Kali tools installation, and automated configuration management.

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/kali-docker-desktop.git
cd kali-docker-desktop

# Start the Kali desktop (auto-starts Docker if needed)
./start.sh
```

That's it! The desktop will appear in a few seconds. No manual Docker startup needed.

## ✨ Features

### Core Features
- **One-click launch** - `./start.sh` handles everything automatically
- **Full Kali desktop** - Complete XFCE4 environment with vertical panel
- **Auto-starts Docker** - Detects and starts Docker Desktop on macOS
- **Smart session detection** - Handles existing X11 sessions gracefully
- **Persistent workspace** - Files and settings preserved across sessions

### Desktop Environment
- **Vertical panel** - Left-side 56px panel with tool launchers
- **Whisker menu** - Hierarchical menu with Kali categories (partial support)
- **Quick launchers** - Direct access to:
  - Terminal, File Manager, Firefox
  - Ghidra, Rizin-Cutter, EDB Debugger
  - Wireshark, Radare2, Binwalk
  - Hexedit, YARA, Volatility3
  - Objdump, Strings, Hexdump
- **Auto-disable sleep** - Prevents container logout/sleep issues

### Tools & Security
- **Kali tools packages** - Automatic installation of:
  - kali-tools-forensics
  - kali-tools-reverse-engineering
  - kali-tools-information-gathering
  - kali-tools-exploitation
  - kali-tools-post-exploitation
  - kali-tools-reporting
  - kali-tools-crypto-stego
- **Malware analysis mode** - Isolated environment setup
- **Claude CLI integrated** - AI assistance (when configured)

## 📖 Documentation

All documentation is organized in the [`docs/`](docs/) directory:

### Getting Started
- [**Quick Start Guide**](docs/QUICK-START.md) - Get up and running in 5 minutes
- [**Setup Guide**](docs/SETUP-GUIDE.md) - Detailed installation instructions
- [**Universal Launch**](docs/UNIVERSAL-LAUNCH.md) - Auto-start Docker feature explained

### Usage & Reference
- [**Usage Guide**](docs/USAGE-GUIDE.md) - Common tasks and workflows
- [**Scripts Reference**](docs/SCRIPTS-REFERENCE.md) - All available commands
- [**X11 GUI Guide**](docs/X11-GUI-Guide.md) - GUI applications and desktop
- [**Tools Inventory**](docs/TOOLS.md) - Complete list of included tools

### Advanced Topics
- [**Architecture**](docs/ARCHITECTURE.md) - System design and components
- [**Malware Analysis Guide**](docs/MALWARE-ANALYSIS-GUIDE.md) - Isolated analysis environment
- [**Project Structure**](docs/PROJECT-STRUCTURE.md) - Repository organization
- [**Migration Plan**](docs/MIGRATION-PLAN.md) - Recent script reorganization

### Help & Security
- [**Troubleshooting**](docs/TROUBLESHOOTING.md) - Common issues and solutions
- [**Security Warning**](docs/SECURITY-WARNING.md) - Important security information

## 🛠️ Basic Commands

```bash
# Start desktop (auto-starts Docker if needed)
./start.sh

# Interactive launcher with menu
./launch.sh

# Launch specific application
./scripts/desktop/launch-app.sh firefox

# Stop container
./scripts/core/stop.sh

# Rebuild container
./scripts/core/rebuild.sh
```

## 🔧 Requirements

### macOS
- Docker Desktop
- XQuartz (`brew install --cask xquartz`)

### Linux
- Docker Engine
- X11 server (usually pre-installed)

### Windows
- Docker Desktop with WSL2
- X server (VcXsrv or similar)

## 🏗️ Project Structure

```
.
├── start.sh              # Main entry point - starts everything
├── launch.sh             # Interactive launcher (if exists)
├── scripts/              # All operational scripts
│   ├── core/            # Container lifecycle
│   │   ├── start.sh     # Start container with mounts
│   │   ├── stop.sh      # Stop container gracefully
│   │   └── rebuild.sh   # Rebuild from Dockerfile
│   ├── desktop/         # Desktop environment
│   │   ├── launch-desktop.sh  # Main desktop launcher
│   │   ├── launch-app.sh      # Individual app launcher
│   │   └── configure-menu.sh  # Menu system configuration
│   ├── tools/           # Tool installation
│   │   ├── install-core.sh    # Essential tools
│   │   ├── install-full.sh    # Complete toolset
│   │   └── install-malware.sh # Malware analysis tools
│   ├── malware/         # Malware analysis
│   │   ├── analyze.sh   # Run analysis
│   │   └── setup-lab.sh # Setup isolated lab
│   ├── utils/           # Support utilities
│   │   ├── ensure-kali-tools.sh    # Auto-install Kali packages
│   │   ├── ensure-panel-tools.sh   # Install panel launchers
│   │   ├── disable-sleep-mode.sh   # Prevent auto-logout
│   │   ├── configure-panel-icons.sh # Setup launcher icons
│   │   └── debug-menu.sh           # Debug menu issues
│   └── deprecated/      # 47 legacy scripts (for reference)
├── docker/              # Docker configuration
│   └── base/           
│       └── Dockerfile   # Main container definition
├── config/              # Persistent configurations
│   ├── xfce4/          # Desktop environment settings
│   │   ├── panel/      # Panel launchers (1-28)
│   │   └── xfconf/     # XFCE configuration
│   └── menus/          # Menu definitions
├── docs/                # Comprehensive documentation
│   ├── getting-started/ # Installation and setup
│   ├── guides/         # How-to guides
│   ├── reference/      # Technical specs
│   ├── troubleshooting/# Problem solving
│   ├── architecture/   # System design
│   └── advanced/       # Historical/specialized
└── workspace/          # User files (persistent)
```

## 🔒 Security Features

- **Network isolation mode** - For malware analysis (`--isolated` flag)
- **Non-root user** - Runs as `kali` user by default
- **Persistent but isolated** - Workspace isolated from host
- **Read-only samples** - Malware samples mounted read-only

## 📊 Current State & Known Issues

### ✅ Working Features
- Container startup and Docker auto-launch
- XFCE4 desktop environment with vertical panel
- Panel tool launchers (all 28 configured)
- Kali tools installation (218+ tools)
- X11 forwarding via XQuartz
- Sleep mode prevention
- Persistent workspace

### ⚠️ Known Issues
- **Whisker Menu**: Categories not fully populating despite tools being installed
  - Only "Forensics" category visible
  - Menu structure changed from numbered (01-15) to named categories
  - `load-hierarchy=true` set but not fully working
- **Initial syntax errors**: Fixed but may need testing
- **Permission handling**: Some operations require root in container

### 📈 Recent Improvements
- **Script consolidation**: 67 total scripts (20 active, 47 deprecated)
- **Automated tools installation**: Runs on every start
- **Fixed duplicate panel icons**: Removed redundant launchers
- **X11 authorization**: Fixed "no protocol specified" errors
- **Menu configuration**: Multiple approaches implemented

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚠️ Disclaimer

This tool is for educational and legitimate security testing purposes only. Users are responsible for complying with all applicable laws and regulations. Never use these tools on systems you don't own or have explicit permission to test.

## 🙏 Acknowledgments

- **Kali Linux team** - For the amazing distribution
- **Docker team** - For containerization technology  
- **XQuartz team** - For X11 on macOS
- **Claude/Anthropic** - For AI assistance integration

---

For detailed documentation, explore the [`docs/`](docs/) directory or start with the [Quick Start Guide](docs/QUICK-START.md).