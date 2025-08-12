# Kali Linux Docker Desktop Environment

A fully-featured Kali Linux desktop environment running in Docker with seamless macOS integration via XQuartz.

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

- **One-click launch** - `./start.sh` handles everything automatically
- **Full Kali desktop** - Complete XFCE4 environment with all tools
- **Auto-starts Docker** - No need to manually start Docker Desktop
- **Smart session detection** - Detects and handles existing sessions gracefully
- **Persistent workspace** - Your files and settings are preserved
- **Malware analysis mode** - Isolated environment for security research
- **Panel tools ready** - Quick access to Ghidra, Wireshark, Rizin-Cutter, YARA
- **Claude CLI integrated** - AI-powered assistance built-in

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
├── start.sh              # Quick start script
├── launch.sh             # Interactive launcher
├── scripts/              # Organized scripts (15 essential scripts)
│   ├── core/            # Container management (start, stop, rebuild)
│   ├── desktop/         # Desktop and apps (launch-desktop, launch-app, configure-menu)
│   ├── tools/           # Tool installation (install-core, install-full, install-malware)
│   ├── malware/         # Malware analysis (analyze, setup-lab)
│   └── utils/           # Utilities (backup, debug, ensure-tools, configure-icons)
├── docker/              # Docker configuration
│   └── base/           # Dockerfile and configs
├── docs/                # All documentation
├── workspace/           # Persistent user files
└── config/             # Persistent configurations
```

## 🔒 Security Features

- **Network isolation mode** - For malware analysis (`--isolated` flag)
- **Non-root user** - Runs as `kali` user by default
- **Persistent but isolated** - Workspace isolated from host
- **Read-only samples** - Malware samples mounted read-only

## 💡 Key Improvements

This project recently underwent major reorganization:
- **52 scripts → 15 essential scripts** (71% reduction)
- **Eliminated duplication** - Single source of truth for each function
- **Smart error handling** - Detects existing sessions, X server conflicts
- **Auto-recovery** - Handles common issues automatically
- **Clean output** - Suppresses unnecessary warnings, shows helpful messages

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