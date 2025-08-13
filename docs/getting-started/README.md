# Getting Started

Everything you need to get your Kali Linux Docker Desktop running.

## 📋 Prerequisites

### macOS
- **Docker Desktop** - [Download](https://www.docker.com/products/docker-desktop/)
- **XQuartz** - Install: `brew install --cask xquartz`

### Linux  
- **Docker Engine** - [Install Guide](https://docs.docker.com/engine/install/)
- **X11** - Usually pre-installed

### Windows
- **Docker Desktop with WSL2** - [Download](https://www.docker.com/products/docker-desktop/)
- **X Server** - VcXsrv or similar

## 🚀 Quick Start (5 minutes)

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/kali-docker-desktop.git
cd kali-docker-desktop
```

### 2. Start Everything
```bash
./start.sh
```

That's it! This single command:
- ✅ Starts Docker Desktop (if not running)
- ✅ Creates/starts the container
- ✅ Launches the XFCE4 desktop
- ✅ Configures everything automatically

### 3. Access Your Environment

The desktop window should appear automatically. If not visible:
- **macOS**: Click the XQuartz icon in the dock
- **Linux**: Check your window manager
- **Windows**: Check VcXsrv window

## 🎯 What You Get

- **Full Kali Linux desktop** with XFCE4
- **100+ security tools** pre-installed
- **Persistent workspace** at `./workspace`
- **Auto-start Docker** feature
- **Smart error handling** for common issues

## 🔧 First Time Setup

### Step 1: Verify Installation
```bash
# Check Docker
docker --version

# Check XQuartz (macOS)
xquartz --version

# Test the setup (optional)
./scripts/testing/test-universal-launch.sh
```

### Step 2: Container Modes

Choose based on your needs:

```bash
# Standard mode (default)
./start.sh

# Interactive menu with options
./launch.sh

# Malware analysis (isolated)
./launch.sh --malware
```

### Step 3: Essential Commands

```bash
# Stop container
./scripts/core/stop.sh

# Shell access
docker exec -it kali-workspace /bin/zsh

# Launch specific app
./scripts/desktop/launch-app.sh firefox
```

## 📁 What's Included

```
/                       # Your host
├── workspace/         # Shared with container (persistent)
├── config/           # Configuration (persistent)
├── scripts/          # 15 essential scripts
│   ├── core/        # Container management
│   ├── desktop/     # GUI management
│   ├── tools/       # Tool installation
│   ├── malware/     # Analysis tools
│   └── utils/       # Utilities
└── docker/          # Container configuration
```

## 🔄 Docker Auto-Start Feature

The `start.sh` script automatically handles Docker:

1. **Detects** if Docker is running
2. **Starts** Docker Desktop if needed (macOS/Linux)
3. **Waits** for Docker to be ready
4. **Launches** your container

No manual Docker management required! See [docker-autostart.md](docker-autostart.md) for details.

## 🆘 Common First-Time Issues

### Docker Not Starting
```bash
# macOS - start manually
open -a Docker

# Linux - start service
sudo systemctl start docker
```

### XQuartz Issues (macOS)
```bash
# Allow connections
xhost +localhost

# Restart XQuartz
killall XQuartz && open -a XQuartz
```

### Desktop Not Appearing
```bash
# Check if desktop is running
docker exec kali-workspace pgrep xfce4-session

# Restart desktop
./scripts/core/stop.sh && ./start.sh
```

## 📚 Next Steps

1. **Explore the desktop** - Click the Kali menu (top-left)
2. **Install more tools** - See [scripts reference](../reference/scripts.md#tool-installation)
3. **Learn the scripts** - See [daily usage](../guides/daily-usage.md)
4. **Customize** - See [configuration options](../reference/structure.md)

## 🔗 Related Documentation

- [Daily Usage Guide](../guides/daily-usage.md) - Common workflows
- [GUI Applications](../guides/gui-applications.md) - Running GUI tools
- [Scripts Reference](../reference/scripts.md) - All available scripts
- [Troubleshooting](../troubleshooting/common-issues.md) - Problem solving

---

**Quick Links:** [Installation Details](installation.md) | [Quick Commands](quickstart.md) | [Auto-Start](docker-autostart.md)