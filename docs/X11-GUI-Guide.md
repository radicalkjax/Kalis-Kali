# Kali Linux GUI Applications on macOS with Docker

This guide covers two ways to run Kali Linux GUI applications on macOS using Docker and X11 forwarding.

## Prerequisites

1. **XQuartz** - X11 server for macOS
   ```bash
   brew install --cask xquartz
   ```

2. **Socat** - Socket relay tool
   ```bash
   brew install socat
   ```

3. **Docker Desktop** - Container runtime
   - Install from [docker.com](https://www.docker.com/products/docker-desktop/)

## Option 1: Individual GUI Applications

This is the recommended approach for running specific tools with better performance.

### Quick Start

```bash
# Launch a specific application
./scripts/kali-gui-app.sh firefox-esr
./scripts/kali-gui-app.sh xfce4-terminal
./scripts/kali-gui-app.sh wireshark
./scripts/kali-gui-app.sh burpsuite
```

### Available Applications

Common GUI tools available in the Kali container:
- `firefox-esr` - Web browser
- `xfce4-terminal` - Terminal emulator
- `gedit` - Text editor
- `wireshark` - Network protocol analyzer
- `burpsuite` - Web security testing
- `metasploit` - Penetration testing framework
- `zenmap` - Network discovery GUI
- `maltego` - OSINT and forensics
- `sqlmap` - SQL injection tool

### Manual Launch

If you prefer to launch apps manually:

```bash
# Ensure X11 bridge is running
./scripts/x11-docker.sh

# Launch application
docker exec -it kali-workspace sh -c "DISPLAY=host.docker.internal:0 <app-name>"
```

## Option 2: Full XFCE4 Desktop Environment

For a complete Kali desktop experience in a window.

### Launch Desktop

```bash
./scripts/kali-desktop.sh
```

This will:
1. Start XQuartz if not running
2. Configure X11 forwarding
3. Start socat TCP bridge
4. Launch XFCE4 desktop in a new window

### Desktop Features

- Full XFCE4 desktop environment
- Application menu with all Kali tools
- File manager (Thunar)
- Terminal emulator
- System tray and panels
- Multiple workspaces

### Stopping the Desktop

- Close the XQuartz window, or
- Press `Ctrl+C` in the terminal

## Troubleshooting

### "Can't open display" Error

1. Check XQuartz is running:
   ```bash
   pgrep -x XQuartz || open -a XQuartz
   ```

2. Verify XQuartz settings:
   - Open XQuartz Preferences
   - Security tab → Enable "Allow connections from network clients"
   - Restart XQuartz after changes

3. Check socat bridge:
   ```bash
   ps aux | grep socat
   # If not running:
   nohup socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:"/tmp/.X11-unix/X0" &
   ```

### "dbus-launch" Error

This is normal for individual apps. If it persists:
```bash
docker exec kali-workspace service dbus start
```

### Performance Issues

- X11 forwarding can be slow for graphics-intensive applications
- Consider using individual apps instead of full desktop
- Close unnecessary applications to free resources

### Container Not Running

```bash
# Check container status
docker ps -a | grep kali

# Start container
docker-compose up -d kali
```

## Advanced Usage

### Custom Display Settings

```bash
# High DPI displays
docker exec -it kali-workspace sh -c "DISPLAY=host.docker.internal:0 GDK_SCALE=2 firefox-esr"

# Force specific resolution
docker exec -it kali-workspace sh -c "DISPLAY=host.docker.internal:0 xrandr --size 1920x1080"
```

### Persistent GUI Settings

GUI application settings are saved in:
- Host: `./config/` (mapped volume)
- Container: `/home/kali/.config/`

### Adding New GUI Applications

```bash
# Install new GUI app
docker exec kali-workspace apt-get update
docker exec kali-workspace apt-get install -y <package-name>

# Launch it
./scripts/kali-gui-app.sh <app-name>
```

## Security Considerations

1. **X11 Security**: The socat bridge opens port 6000. This is only accessible locally but be aware of the security implications.

2. **Container Privileges**: The container runs with elevated privileges for certain tools. Use responsibly.

3. **Network Access**: GUI applications have full network access through the container.

## Tips for Best Experience

1. **Use Individual Apps**: Better performance than full desktop
2. **Close Unused Apps**: Free up resources
3. **Save Work Frequently**: Container restarts will close all apps
4. **Use Workspace Volume**: Save files in `/home/kali/workspace` for persistence

## Common Use Cases

### Web Application Testing
```bash
./scripts/kali-gui-app.sh firefox-esr
./scripts/kali-gui-app.sh burpsuite
```

### Network Analysis
```bash
./scripts/kali-gui-app.sh wireshark
./scripts/kali-gui-app.sh zenmap
```

### Development
```bash
./scripts/kali-gui-app.sh code  # If VS Code installed
./scripts/kali-gui-app.sh gedit
```

### Full Testing Environment
```bash
./scripts/kali-desktop.sh  # Full desktop with all tools
```