# Universal Launch Experience

## One Command to Rule Them All

```bash
./start.sh
```

That's it. This single command handles **everything**:

## What It Does Automatically

### 1. 🐳 Starts Docker Desktop
- Detects if Docker is not running
- Automatically launches Docker Desktop (macOS)
- Waits for Docker to be ready
- No manual Docker startup needed

### 2. 🚀 Launches Container
- Starts the Kali container
- Resumes if already exists
- Creates new if needed

### 3. 🛠️ Ensures Tools
- Verifies all panel tools installed
- Installs missing tools automatically
- Handles package name changes

### 4. 🎨 Configures Icons
- Sets proper security-themed icons
- Replaces generic gear icons
- Professional appearance

### 5. 🖥️ Launches Desktop
- Starts XQuartz if needed
- Launches XFCE4 desktop
- All tools ready to use

## Alternative: Interactive Menu

For more control, use the interactive launcher:

```bash
./launch.sh
```

This provides a menu with options for:
- Shell or desktop launch
- Tool installation
- Configuration management
- Container control

## Zero Prerequisites Running

You don't need to:
- ❌ Start Docker manually
- ❌ Check if container exists
- ❌ Install tools manually
- ❌ Configure anything
- ❌ Start XQuartz manually

Everything is handled automatically!

## Quick Launch Options

### Simple Desktop
```bash
./start.sh
```

### Interactive Menu
```bash
./launch.sh
```

### Direct Commands
```bash
./launch.sh --shell     # Shell only
./launch.sh --desktop   # Desktop only
./launch.sh --malware   # Isolated malware lab
```

## How It Works

### Docker Auto-Start (macOS)
```bash
# Detects Docker not running
if ! docker info &> /dev/null; then
    # Starts Docker Desktop
    open -a Docker
    # Waits up to 60 seconds
    # Shows progress dots
fi
```

### Container Management
```bash
# Checks if container exists
# Starts or creates as needed
# Verifies all tools installed
# Configures desktop environment
```

### Complete Flow
1. **User runs**: `./start.sh`
2. **Script checks**: Is Docker running?
   - No → Starts Docker Desktop automatically
   - Yes → Continues
3. **Script checks**: Is container running?
   - No → Starts/creates container
   - Yes → Continues
4. **Script ensures**: Tools installed, icons configured
5. **Script launches**: Desktop environment
6. **User sees**: Fully configured Kali desktop

## Supported Platforms

### macOS ✅
- Auto-starts Docker Desktop app
- Auto-starts XQuartz for GUI
- Full automation supported

### Linux ✅
- Auto-starts Docker service (systemctl/service)
- Native X11 support
- May require sudo for Docker service

### Windows 🔶
- Docker Desktop must be started manually
- WSL2 recommended
- X server needed for GUI

## Testing Your Setup

Run the test script to verify everything works:

```bash
./scripts/testing/test-universal-launch.sh
```

Expected output:
```
✓ launch.sh exists and is executable
✓ start.sh exists and is executable
✓ Docker Desktop is installed on macOS
✓ Scripts will auto-start Docker if not running
✓ XQuartz is installed
✓ Universal launch experience is ready!
```

## Troubleshooting

### Docker Won't Start
- **macOS**: Check Docker Desktop is installed in /Applications
- **Linux**: Check you have permissions for Docker service
- **All**: Verify Docker Desktop is not corrupted

### Container Won't Start
- Run: `./scripts/core/rebuild.sh`
- Check disk space
- Check Docker logs

### Tools Missing
- Run: `docker exec --user root kali-workspace /home/kali/scripts/utils/ensure-panel-tools.sh`

### Icons Not Showing
- Restart panel: `docker exec --user kali kali-workspace xfce4-panel -r`

## The Magic

With this universal launch experience, going from zero to a fully configured Kali Linux security environment is literally:

1. Clone repo
2. Run `./start.sh`
3. Work

No manual steps. No configuration. No prerequisites to start manually.

**It just works.** 🎉