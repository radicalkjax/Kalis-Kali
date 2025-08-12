# 🚀 Complete Setup Guide

This guide will walk you through setting up the Kali Linux Docker containers from start to finish.

## 📋 Prerequisites

```mermaid
graph LR
    A[macOS] --> B[Docker Desktop]
    A --> C[XQuartz]
    A --> D[Git]
    A --> E[8GB+ RAM]
    
    B --> F[Docker Running]
    C --> G[X11 Support]
    D --> H[Clone Repo]
    E --> I[Performance]
    
    style A fill:#e3f2fd,stroke:#1565c0,stroke-width:3px
    style B fill:#fff3e0,stroke:#ef6c00,stroke-width:2px
    style C fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
```

### System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| macOS | 10.15 (Catalina) | 12.0+ (Monterey) |
| RAM | 8GB | 16GB+ |
| Storage | 20GB free | 50GB+ free |
| CPU | Intel/M1 | M1/M2 Pro |

### Required Software

1. **Docker Desktop for Mac**
   ```bash
   # Download from Docker website or use Homebrew
   brew install --cask docker
   ```

2. **XQuartz** (for GUI support)
   ```bash
   brew install --cask xquartz
   # Restart required after installation
   ```

3. **Git** (usually pre-installed)
   ```bash
   # Verify installation
   git --version
   ```

## 🔧 Installation Steps

```mermaid
flowchart TD
    A[Start] --> B[Install Prerequisites]
    B --> C[Clone Repository]
    C --> D[Configure Environment]
    D --> E{Choose Setup Type}
    E -->|Standard| F[Start Standard Container]
    E -->|Malware| G[Start Secure Malware Container]
    F --> H[Access Container]
    G --> H[Access Container]
    H --> I[Setup Complete]
    
    style A fill:#f9f,stroke:#333,stroke-width:3px
    style I fill:#9f9,stroke:#333,stroke-width:3px
    style E fill:#ff9,stroke:#333,stroke-width:2px
```

### Step 1: Clone the Repository

```bash
# Clone the repository
git clone https://github.com/yourusername/kali-docker.git
cd kali-docker

# Or download and extract ZIP
curl -L https://github.com/yourusername/kali-docker/archive/main.zip -o kali-docker.zip
unzip kali-docker.zip
cd kali-docker-main
```

### Step 2: Configure Environment

```bash
# Copy environment template
cp .env.example .env

# Edit .env file
nano .env
```

#### For Claude Max/Pro Users:
```env
CLAUDE_AUTH_METHOD=max
# Leave ANTHROPIC_API_KEY empty
```

#### For API Key Users:
```env
CLAUDE_AUTH_METHOD=api
ANTHROPIC_API_KEY=your-api-key-here
```

### Step 3: Initial Setup

```mermaid
sequenceDiagram
    participant User
    participant Terminal
    participant Docker
    participant Container
    
    User->>Terminal: ./scripts/start-kali.sh
    Terminal->>Docker: Check Docker daemon
    Docker-->>Terminal: Running
    Terminal->>Docker: Pull kali-rolling:latest
    Docker-->>Terminal: Image downloaded
    Terminal->>Docker: Build custom image
    Docker-->>Terminal: Build complete
    Terminal->>Docker: Start containers
    Docker->>Container: Initialize
    Container-->>Docker: Ready
    Docker-->>Terminal: Container ID
    Terminal-->>User: Success! Access info displayed
```

Run the setup:
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Start standard Kali container
./scripts/start-kali.sh
```

### Step 4: Verify Installation

```bash
# Check running containers
docker ps

# You should see:
CONTAINER ID   IMAGE              CONTAINER NAME    STATUS
xxxxxxxxxxxx   kali-custom:latest kali-workspace   Up 2 minutes
```

## 🖥️ Access Methods

```mermaid
graph TB
    subgraph "Access Options"
        A[Container Running]
        A --> B[CLI Access]
        A --> C[X11 Forwarding]
        
        B --> B1[docker exec -it kali-workspace /bin/bash]
        C --> C1[./scripts/run-gui.sh <app>]
        C --> C2[Native macOS Windows]
    end
    
    style A fill:#e8f5e9,stroke:#2e7d32,stroke-width:3px
    style C fill:#e3f2fd,stroke:#1565c0,stroke-width:2px
```

### 1. Command Line Interface (CLI)

```bash
# Basic access
docker exec -it kali-workspace /bin/bash

# As root (if needed)
docker exec -it -u root kali-workspace /bin/bash

# Run specific command
docker exec kali-workspace nmap --version
```

### 2. GUI Access via X11 Forwarding

```bash
# GUI apps run as native macOS windows
./scripts/run-gui.sh firefox
./scripts/run-gui.sh burpsuite

# Or run full desktop
./scripts/run-gui.sh startxfce4
```

## 🐋 Container Management

```mermaid
stateDiagram-v2
    [*] --> Stopped: Initial State
    Stopped --> Starting: ./scripts/start-kali.sh
    Starting --> Running: Container Started
    Running --> Stopping: ./scripts/stop-kali.sh
    Stopping --> Stopped: Container Stopped
    Running --> Paused: docker pause
    Paused --> Running: docker unpause
    Running --> Restarting: docker restart
    Restarting --> Running: Container Restarted
    Stopped --> Removed: docker-compose down
    Removed --> [*]: Container Deleted
```

### Common Commands

| Action | Command |
|--------|---------|
| Start containers | `./scripts/start-kali.sh` |
| Stop containers | `./scripts/stop-kali.sh` |
| Restart container | `docker restart kali-workspace` |
| View logs | `docker logs kali-workspace` |
| Remove containers | `docker-compose down` |
| Remove everything | `docker-compose down -v --rmi all` |

## 🔧 Post-Installation Setup

### 1. Install Additional Tools

```bash
# Inside container
docker exec -it kali-workspace /bin/bash

# Run setup script
/home/kali/scripts/setup-tools.sh
```

### 2. Configure Claude CLI

```bash
# For Max/Pro users
docker exec -it kali-workspace /home/kali/scripts/setup-claude.sh
# Select option 1

# For API key users (if not auto-configured)
docker exec -it kali-workspace /home/kali/scripts/setup-claude.sh
# Select option 2
```

### 3. Setup Malware Analysis Environment

```bash
# Inside container
docker exec -it kali-workspace /home/kali/scripts/setup-malware-analysis.sh
```

## 🚨 Troubleshooting Quick Fixes

```mermaid
graph TD
    A[Problem] --> B{What's Wrong?}
    B -->|Docker not running| C[Start Docker Desktop]
    B -->|Port in use| D[Change port in docker-compose.yml]
    B -->|GUI apps not working| E[Check XQuartz settings]
    B -->|Build fails| F[Clear cache and rebuild]
    
    C --> G[Solution]
    D --> G
    E --> G
    F --> G
    
    style A fill:#ffcdd2,stroke:#d32f2f,stroke-width:2px
    style G fill:#c8e6c9,stroke:#388e3c,stroke-width:2px
```

### Common Issues

1. **Docker daemon not running**
   ```bash
   # Start Docker Desktop
   open -a Docker
   ```

2. **Port already in use**
   ```bash
   # Find process using port
   lsof -i :5901
   # Change port in docker-compose.yml
   ```

3. **XQuartz connection refused**
   ```bash
   # Allow connections
   defaults write org.xquartz.X11 enable_iglx -bool true
   xhost +localhost
   ```

## ✅ Verification Checklist

- [ ] Docker Desktop is running
- [ ] Container shows as "Up" in `docker ps`
- [ ] Can access CLI with `docker exec`
- [ ] X11 forwarding works (GUI apps open)
- [ ] Persistent storage mounted correctly
- [ ] Network connectivity works (ping google.com)

## 📚 Next Steps

1. Read [USAGE-GUIDE.md](./USAGE-GUIDE.md) for common workflows
2. Check [SECURITY-WARNING.md](./SECURITY-WARNING.md) for security info
3. Explore [TOOLS.md](./TOOLS.md) for available tools
4. Configure settings in [CONFIGURATION.md](./CONFIGURATION.md)

## 🆘 Getting Help

If you encounter issues:
1. Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
2. Review container logs: `docker logs kali-workspace`
3. Verify prerequisites are installed
4. Ensure sufficient system resources