# Panel Tools Fix Documentation

## Problem
Cutter and other tools in the taskbar/panel were inaccessible because:
1. Tools referenced in panel launchers weren't installed in the container
2. Cutter package name changed from `cutter` to `rizin-cutter` in recent Kali versions
3. No automatic verification of panel tool requirements

## Solution Implemented

### 1. Created Panel Tools Verification Script
**File**: `/scripts/utils/ensure-panel-tools.sh`
- Checks all tools required by panel launchers
- Installs missing tools automatically
- Handles package name changes (e.g., cutter → rizin-cutter)
- Creates symlinks for backward compatibility
- Must run as root for package installation

### 2. Updated Dockerfile
**File**: `/docker/base/Dockerfile`
- Added all panel-required tools to default installation:
  - `rizin-cutter` (instead of `cutter`)
  - `ghidra`, `radare2`, `edb-debugger`
  - `binwalk`, `hexedit`, `yara`
  - `wireshark`, `volatility3`
- Creates symlink from `cutter` to `rizin-cutter` for compatibility

### 3. Integrated into Startup Process
**File**: `/scripts/core/start.sh`
- Automatically checks for missing panel tools on container start
- Runs ensure-panel-tools.sh as root if tools are missing
- Ensures panel launchers always work

## Tools in Panel

| Launcher | Tool | Package | Purpose |
|----------|------|---------|---------|
| launcher-3 | Terminal | (built-in) | Terminal emulator |
| launcher-4 | Ghidra | ghidra | Reverse engineering |
| launcher-5 | Cutter | rizin-cutter | RE GUI (Rizin-based) |
| launcher-6 | EDB | edb-debugger | Linux debugger |
| launcher-7 | Wireshark | wireshark | Network analysis |
| launcher-8 | Volatility3 | volatility3 | Memory forensics |
| launcher-9 | Hexedit | hexedit | Hex editor |
| launcher-10 | Binwalk | binwalk | Firmware analysis |
| launcher-11 | YARA | yara | Malware patterns |
| launcher-23-28 | Various | Various | Additional tools |

## How It Works

### On Container Start
```bash
./scripts/core/start.sh
# → Checks if critical tools exist
# → If missing, runs ensure-panel-tools.sh as root
# → Installs missing packages
# → Creates compatibility symlinks
```

### Manual Fix
```bash
# If panel tools are broken:
docker exec --user root kali-workspace /home/kali/scripts/utils/ensure-panel-tools.sh

# Restart panel to refresh:
docker exec --user kali kali-workspace xfce4-panel -r
```

### After Rebuild
When rebuilding container with:
```bash
./scripts/core/rebuild.sh
```
All panel tools will be pre-installed via updated Dockerfile.

## Key Changes

### Package Name Updates
- `cutter` → `rizin-cutter` (Cutter moved to Rizin framework)
- Symlink created: `/usr/bin/cutter` → `/usr/bin/rizin-cutter`

### Security Considerations
- Script requires root to install packages (no sudo in container)
- Runs as `docker exec --user root` when needed
- Normal operations still run as `kali` user

## Testing

To verify all panel tools work:
```bash
# Check installation status
docker exec kali-workspace bash -c "
for tool in cutter ghidra wireshark radare2 edb hexedit binwalk yara volatility3; do
    if command -v \$tool >/dev/null 2>&1; then
        echo '✓ '\$tool
    else
        echo '✗ '\$tool
    fi
done
"
```

## Result
- All panel launchers now work correctly
- Tools automatically installed on container start
- Future-proof with package name change handling
- No more "command not found" errors when clicking panel icons