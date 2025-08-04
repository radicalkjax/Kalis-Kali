# Scripts Reference Guide

This document provides a comprehensive reference for all scripts in the `/scripts` directory.

## Container Management Scripts

### start-kali.sh
Starts the main Kali Linux container with GUI support.
```bash
./scripts/start-kali.sh
```

### stop-kali.sh
Stops all running Kali containers.
```bash
./scripts/stop-kali.sh
```

## GUI and Desktop Scripts

### kali-desktop.sh
Launches the full XFCE4 desktop environment with all Kali tools accessible through the Applications Menu.
```bash
./scripts/kali-desktop.sh
```

### kali-gui-app.sh
Runs individual GUI applications in native macOS windows.
```bash
./scripts/kali-gui-app.sh <application-name>
# Examples:
./scripts/kali-gui-app.sh firefox-esr
./scripts/kali-gui-app.sh burpsuite
./scripts/kali-gui-app.sh wireshark
```

### run-gui.sh
Legacy script for running GUI applications (use kali-gui-app.sh instead).

### setup-x11.sh
Sets up X11 forwarding prerequisites on macOS.
```bash
./scripts/setup-x11.sh
```

### x11-docker.sh
Starts the X11 forwarding bridge for Docker containers.
```bash
./scripts/x11-docker.sh
```

### start-proper-desktop.sh
Starts a complete desktop environment with proper session management and all components.
```bash
./scripts/start-proper-desktop.sh
```

## Menu Fix Scripts

### fix-applications-menu.sh
Fixes the XFCE Applications Menu to properly display Kali tool categories.
```bash
./scripts/fix-applications-menu.sh
```

### fix-kali-menu.sh
Basic menu fix script that updates desktop database and clears caches.
```bash
./scripts/fix-kali-menu.sh
```

### fix-kali-tools-menu.sh
Comprehensive script that installs missing tools and rebuilds the entire menu system.
```bash
./scripts/fix-kali-tools-menu.sh
```

### fix-panel-menu.sh
Replaces Directory Menu with Applications Menu in the XFCE panel.
```bash
./scripts/fix-panel-menu.sh
```

### fix-panel-properly.sh
Complete panel reset and configuration with Whisker Menu.
```bash
./scripts/fix-panel-properly.sh
```

### fix-root-desktop-menu.sh
Fixes desktop menu specifically for root user (container default).
```bash
./scripts/fix-root-desktop-menu.sh
```

### rebuild-xfce-menu.sh
Rebuilds the XFCE application database and clears all menu caches.
```bash
./scripts/rebuild-xfce-menu.sh
```

### replace-directory-menu.sh
Directly replaces Directory Menu plugin with Applications Menu plugin.
```bash
./scripts/replace-directory-menu.sh
```

### restore-panel.sh
Restores XFCE panel to default configuration if it becomes corrupted.
```bash
./scripts/restore-panel.sh
```

### install-applications-menu.sh
Installs and configures the Applications Menu plugin.
```bash
./scripts/install-applications-menu.sh
```

### setup-whisker-menu.sh
Installs and configures Whisker Menu (modern alternative to Applications Menu).
```bash
./scripts/setup-whisker-menu.sh
```

## Tool Installation Scripts

### install-all-kali-tools.sh
Installs all Kali Linux tools (takes significant time and disk space).
```bash
./scripts/install-all-kali-tools.sh
```

### setup-tools.sh
Installs additional useful tools not included in the base image.
```bash
./scripts/setup-tools.sh
```

## Claude Integration

### setup-claude.sh
Configures Claude CLI inside the container for AI assistance.
```bash
./scripts/setup-claude.sh [api-key]
# Or set ANTHROPIC_API_KEY environment variable
# Or use CLAUDE_AUTH_METHOD=max for Max plan users
```

## Malware Analysis Scripts

### setup-malware-analysis.sh
Sets up the malware analysis environment with required tools.
```bash
./scripts/setup-malware-analysis.sh
```

### start-malware-lab.sh
Starts the insecure malware analysis lab (for learning only).
```bash
./scripts/start-malware-lab.sh
```

### start-secure-malware-lab.sh
Starts the secure 3-tier malware analysis environment.
```bash
./scripts/start-secure-malware-lab.sh
```

### safe-analyze.sh
Safely analyzes a malware sample with proper isolation.
```bash
./scripts/safe-analyze.sh <sample-path>
```

## Script Categories Summary

| Category | Scripts | Purpose |
|----------|---------|---------|
| **Container Management** | start-kali.sh, stop-kali.sh | Start/stop containers |
| **GUI Setup** | setup-x11.sh, x11-docker.sh | Configure X11 forwarding |
| **Desktop Environment** | kali-desktop.sh, start-proper-desktop.sh | Launch full desktop |
| **Individual Apps** | kali-gui-app.sh | Run specific GUI tools |
| **Menu Fixes** | fix-*.sh, rebuild-*.sh, restore-*.sh | Fix application menus |
| **Tool Installation** | install-all-kali-tools.sh, setup-tools.sh | Add more tools |
| **Claude Integration** | setup-claude.sh | Configure AI assistant |
| **Malware Analysis** | *-malware-*.sh, safe-analyze.sh | Malware analysis setup |

## Common Workflows

### First Time Setup
```bash
./scripts/setup-x11.sh
./scripts/start-kali.sh
./scripts/setup-claude.sh
```

### Daily Use - GUI Apps
```bash
./scripts/kali-gui-app.sh firefox-esr
./scripts/kali-gui-app.sh burpsuite
```

### Daily Use - Full Desktop
```bash
./scripts/kali-desktop.sh
```

### Fix Missing Applications in Menu
```bash
./scripts/fix-kali-tools-menu.sh
# Then restart desktop or panel
```

### Malware Analysis
```bash
./scripts/start-secure-malware-lab.sh
./scripts/safe-analyze.sh /path/to/sample
```

## Troubleshooting

If scripts fail, check:
1. Container is running: `docker ps | grep kali`
2. XQuartz is installed: `brew list --cask | grep xquartz`
3. Socat is installed: `brew list | grep socat`
4. X11 permissions: XQuartz → Preferences → Security → "Allow connections"

For specific issues, see [TROUBLESHOOTING.md](./TROUBLESHOOTING.md).