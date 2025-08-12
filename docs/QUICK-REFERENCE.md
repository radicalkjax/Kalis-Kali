# Quick Reference Cheatsheet

Essential commands and paths for daily use.

## 🚀 Starting & Stopping

```bash
# Start everything (auto-starts Docker)
./start.sh

# Interactive menu
./launch.sh

# Stop container
./scripts/core/stop.sh

# Restart container
./scripts/core/stop.sh && ./scripts/core/start.sh
```

## 🖥️ Desktop & GUI

```bash
# Launch desktop
./scripts/desktop/launch-desktop.sh

# Launch specific app
./scripts/desktop/launch-app.sh firefox
./scripts/desktop/launch-app.sh wireshark
./scripts/desktop/launch-app.sh burpsuite

# Fix menu issues
docker exec kali-workspace /home/kali/scripts/desktop/configure-menu.sh
```

## 🐚 Container Access

```bash
# Shell access
docker exec -it kali-workspace /bin/zsh

# Root shell
docker exec -it --user root kali-workspace /bin/bash

# Check container status
docker ps | grep kali

# View logs
docker logs kali-workspace
```

## 🛠️ Tool Installation

```bash
# Install core tools
docker exec kali-workspace /home/kali/scripts/tools/install-core.sh

# Install full toolset
docker exec kali-workspace /home/kali/scripts/tools/install-full.sh

# Install malware tools
docker exec kali-workspace /home/kali/scripts/tools/install-malware.sh

# Install single tool
docker exec kali-workspace apt install -y <tool-name>
```

## 🔬 Malware Analysis

```bash
# Start isolated malware lab
./launch.sh --malware

# Access malware container
docker exec -it kali-malware-isolated /bin/zsh

# Setup malware environment
docker exec kali-malware-isolated /home/kali/scripts/malware/setup-lab.sh

# Analyze sample
docker exec kali-malware-isolated /home/kali/scripts/malware/analyze.sh <file>
```

## 📁 Important Paths

### Host Machine
```
./                      # Project root
./workspace/            # Persistent workspace (shared)
./config/              # Persistent configuration
./scripts/             # All scripts
./docker/base/         # Dockerfile and configs
./docs/                # Documentation
```

### Inside Container
```
/home/kali/            # Home directory
/home/kali/workspace/  # Shared workspace
/home/kali/.config/    # Configuration
/home/kali/scripts/    # Container scripts
```

## 🔧 Utility Commands

```bash
# Backup configuration
docker exec kali-workspace /home/kali/scripts/utils/backup-config.sh

# Ensure panel tools installed
docker exec --user root kali-workspace /home/kali/scripts/utils/ensure-panel-tools.sh

# Configure panel icons
docker exec kali-workspace /home/kali/scripts/utils/configure-panel-icons.sh

# Debug menu issues
docker exec kali-workspace /home/kali/scripts/utils/debug-menu.sh
```

## 🔄 Container Management

```bash
# Rebuild container
./scripts/core/rebuild.sh

# Clean rebuild
./scripts/core/rebuild.sh --no-cache

# Remove container
docker rm -f kali-workspace

# Remove image
docker rmi kali-workspace:latest
```

## 🌐 Network Modes

```bash
# Standard mode (with network)
./scripts/core/start.sh

# Malware mode (with network)
./scripts/core/start.sh --malware

# Isolated mode (no network)
./scripts/core/start.sh --isolated
```

## ⚙️ Environment Variables

```bash
# Display configuration
DISPLAY=host.docker.internal:0

# Container names
kali-workspace          # Standard container
kali-malware           # Malware with network
kali-malware-isolated  # Isolated malware
```

## 🆘 Troubleshooting Commands

```bash
# Check Docker status
docker info

# Start Docker (macOS)
open -a Docker

# Allow X11 connections
xhost +localhost

# Check XQuartz (macOS)
pgrep -x XQuartz

# Test X11 display
docker exec kali-workspace xeyes

# Check for running desktop
docker exec kali-workspace pgrep xfce4-session
```

## 📜 Script Organization

```
scripts/
├── core/
│   ├── start.sh       # Start container
│   ├── stop.sh        # Stop container
│   └── rebuild.sh     # Rebuild image
├── desktop/
│   ├── launch-desktop.sh    # Launch desktop
│   ├── launch-app.sh        # Launch apps
│   └── configure-menu.sh    # Fix menus
├── tools/
│   ├── install-core.sh      # Core tools
│   ├── install-full.sh      # All tools
│   └── install-malware.sh   # Malware tools
├── malware/
│   ├── setup-lab.sh         # Setup environment
│   └── analyze.sh           # Analyze samples
└── utils/
    ├── backup-config.sh      # Backup/restore
    ├── ensure-panel-tools.sh # Install panel tools
    ├── configure-panel-icons.sh # Fix icons
    ├── debug-menu.sh         # Debug menus
    └── setup-claude.sh       # Setup Claude CLI
```

## 🔗 Symlinks (Backward Compatibility)

```bash
scripts/start-kali.sh → core/start.sh
scripts/stop-kali.sh → core/stop.sh
scripts/kali-desktop.sh → desktop/launch-desktop.sh
scripts/kali-gui-app.sh → desktop/launch-app.sh
```

## 📝 Common Workflows

### Fresh Start
```bash
./scripts/core/stop.sh
./scripts/core/rebuild.sh
./start.sh
```

### Daily Use
```bash
./start.sh                    # Morning startup
# ... work ...
./scripts/core/stop.sh        # End of day
```

### Development
```bash
docker exec -it kali-workspace /bin/zsh
cd workspace
# ... code ...
```

### Security Testing
```bash
./start.sh
./scripts/desktop/launch-app.sh burpsuite
./scripts/desktop/launch-app.sh wireshark
```

---

**See Also:** [Scripts Reference](reference/SCRIPTS-REFERENCE.md) | [Troubleshooting](troubleshooting/TROUBLESHOOTING.md)