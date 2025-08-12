# Scripts Reference

All 15 essential scripts documented with examples.

## 📁 Script Organization

```
scripts/
├── core/        # Container management (3 scripts)
├── desktop/     # GUI management (3 scripts)
├── tools/       # Tool installation (3 scripts)
├── malware/     # Analysis tools (2 scripts)
└── utils/       # Utilities (4+ scripts)
```

## 🚀 Root Launch Scripts

### `start.sh`
One-click launch with Docker auto-start.
```bash
./start.sh
```
**Features:**
- Starts Docker Desktop if not running
- Creates/starts container
- Launches XFCE4 desktop
- Detects existing sessions

### `launch.sh`
Interactive menu system.
```bash
./launch.sh           # Interactive menu
./launch.sh --shell   # Direct shell
./launch.sh --desktop # Direct desktop
./launch.sh --malware # Malware lab
```

## 🎯 Core Scripts (`scripts/core/`)

### `start.sh`
Container lifecycle management.
```bash
./scripts/core/start.sh              # Default start
./scripts/core/start.sh --malware    # Malware mode
./scripts/core/start.sh --isolated   # No network
./scripts/core/start.sh --rebuild    # Force rebuild
```

### `stop.sh`
Stop all Kali containers.
```bash
./scripts/core/stop.sh
```

### `rebuild.sh`
Rebuild container image.
```bash
./scripts/core/rebuild.sh            # Standard rebuild
./scripts/core/rebuild.sh --no-cache # Clean rebuild
```

## 🖥️ Desktop Scripts (`scripts/desktop/`)

### `launch-desktop.sh`
Launch XFCE4 desktop or apps.
```bash
./scripts/desktop/launch-desktop.sh              # Full desktop
./scripts/desktop/launch-desktop.sh --app firefox # Specific app
./scripts/desktop/launch-desktop.sh --minimal    # Light desktop
```
**Smart Features:**
- Detects "X server already running" errors
- Handles existing desktop sessions
- Auto-configures XQuartz on macOS

### `launch-app.sh`
Launch individual GUI applications.
```bash
./scripts/desktop/launch-app.sh firefox
./scripts/desktop/launch-app.sh wireshark
./scripts/desktop/launch-app.sh burpsuite
./scripts/desktop/launch-app.sh ghidra
```

### `configure-menu.sh`
Fix all menu issues (consolidates 26 old scripts).
```bash
docker exec kali-workspace /home/kali/scripts/desktop/configure-menu.sh
```
**Fixes:**
- Kali menu installation
- Whisker menu configuration
- Category display issues
- Panel launcher problems

## 🛠️ Tool Scripts (`scripts/tools/`)

### `install-core.sh`
Essential security tools.
```bash
docker exec kali-workspace /home/kali/scripts/tools/install-core.sh
```
**Installs:**
- Metasploit, Nmap, Burp Suite
- SQLMap, John, Hashcat
- Hydra, Netcat, Gobuster

### `install-full.sh`
Complete Kali toolset.
```bash
docker exec kali-workspace /home/kali/scripts/tools/install-full.sh
```
**Installs:**
- kali-linux-default metapackage
- Web application tools
- Wireless tools
- Forensics tools
- Reverse engineering tools

### `install-malware.sh`
Malware analysis tools.
```bash
docker exec kali-workspace /home/kali/scripts/tools/install-malware.sh
```
**Installs:**
- YARA with rules
- Ghidra, Radare2, Rizin
- Volatility3
- PE/ELF analyzers
- Document analyzers

## 🔬 Malware Scripts (`scripts/malware/`)

### `setup-lab.sh`
Initialize malware analysis environment.
```bash
docker exec kali-malware-isolated /home/kali/scripts/malware/setup-lab.sh
```
**Creates:**
- Analysis workspace structure
- Downloads YARA rules
- Python virtual environment
- Analysis scripts

### `analyze.sh`
Automated malware analysis.
```bash
docker exec kali-malware-isolated /home/kali/scripts/malware/analyze.sh sample.exe
```
**Performs:**
- Static analysis
- YARA scanning
- String extraction
- PE/ELF analysis
- Report generation

## 🔧 Utility Scripts (`scripts/utils/`)

### `ensure-panel-tools.sh`
Install all panel launcher tools.
```bash
docker exec --user root kali-workspace /home/kali/scripts/utils/ensure-panel-tools.sh
```
**Ensures:**
- Ghidra installed
- Rizin-Cutter (handles rename from cutter)
- Wireshark (full package)
- All panel tools accessible

### `configure-panel-icons.sh`
Set proper panel icons.
```bash
docker exec kali-workspace /home/kali/scripts/utils/configure-panel-icons.sh
```
**Configures:**
- Security-themed icons
- Replaces generic gears
- Professional appearance

### `backup-config.sh`
Backup/restore configuration.
```bash
# Backup
docker exec kali-workspace /home/kali/scripts/utils/backup-config.sh

# Restore
docker exec kali-workspace /home/kali/scripts/utils/backup-config.sh -r backup-20240812.tar.gz
```

### `debug-menu.sh`
Debug menu issues.
```bash
docker exec kali-workspace /home/kali/scripts/utils/debug-menu.sh
```
**Checks:**
- Menu installation
- .desktop files
- Menu database
- Category assignments

### `setup-claude.sh`
Configure Claude CLI.
```bash
docker exec -it kali-workspace /home/kali/scripts/utils/setup-claude.sh
```

### `test-panel-tools.sh`
Verify panel tools.
```bash
docker exec kali-workspace /home/kali/scripts/utils/test-panel-tools.sh
```

## 🔗 Backward Compatibility

Symlinks for old script names:
```bash
scripts/start-kali.sh → core/start.sh
scripts/stop-kali.sh → core/stop.sh
scripts/kali-desktop.sh → desktop/launch-desktop.sh
scripts/kali-gui-app.sh → desktop/launch-app.sh
```

## 📦 Deprecated Scripts

46 old scripts archived in `scripts/deprecated/`:
- `menu-fixes/` - 28 scripts → replaced by `configure-menu.sh`
- `installation/` - 5 scripts → replaced by `tools/` scripts
- `malware/` - 5 scripts → replaced by current `malware/` scripts
- `launch/` - 3 scripts → replaced by unified launchers
- `testing/` - 3 test scripts
- `other/` - 2 miscellaneous scripts

## 💡 Usage Examples

### Daily Workflow
```bash
# Morning
./start.sh                                    # Start everything

# Work
./scripts/desktop/launch-app.sh burpsuite    # Launch tools
docker exec -it kali-workspace /bin/zsh      # Shell work

# Evening  
./scripts/core/stop.sh                       # Shutdown
```

### Fresh Installation
```bash
./scripts/core/rebuild.sh                    # Build image
./start.sh                                   # Start
docker exec kali-workspace /home/kali/scripts/tools/install-core.sh  # Install tools
```

### Malware Analysis
```bash
./launch.sh --malware                        # Start isolated
docker exec -it kali-malware-isolated /bin/zsh
~/scripts/malware/setup-lab.sh              # Setup
~/scripts/malware/analyze.sh sample.bin     # Analyze
```

### Troubleshooting
```bash
# Fix menus
docker exec kali-workspace /home/kali/scripts/desktop/configure-menu.sh

# Ensure tools
docker exec --user root kali-workspace /home/kali/scripts/utils/ensure-panel-tools.sh

# Debug issues
docker exec kali-workspace /home/kali/scripts/utils/debug-menu.sh
```

## 🔍 Script Features

### Error Handling
- Detects Docker not running → starts it
- Detects X server conflicts → provides guidance
- Detects existing sessions → prevents duplicates

### Idempotent
- Safe to run multiple times
- Won't break existing setup
- Handles partial failures

### Cross-Platform
- macOS: XQuartz integration
- Linux: Native X11
- Windows: X server support

## 📝 Notes

- All paths relative to project root unless specified
- Container name: `kali-workspace` (standard), `kali-malware-isolated` (malware)
- Scripts require executable permissions (`chmod +x`)
- Some utils need root: use `--user root` flag

---

**See Also:** [Quick Reference](../QUICK-REFERENCE.md) | [Daily Usage](../guides/daily-usage.md) | [Troubleshooting](../troubleshooting/common-issues.md)