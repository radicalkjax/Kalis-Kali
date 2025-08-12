# Kali Container - Quick Start Guide

## 🚀 Fastest Way to Start

```bash
./start.sh
```

This launches the Kali desktop environment with all tools ready to use.

## 🎯 Unified Launcher

For more control, use the interactive launcher:

```bash
./launch.sh
```

This provides a menu with all options:
- Launch shell or desktop
- Install tools (core/full/malware)
- Configure menus
- Manage container

### Quick Launch Options

Skip the menu with direct commands:

```bash
./launch.sh --shell     # Open shell directly
./launch.sh --desktop   # Launch desktop directly
./launch.sh --malware   # Launch isolated malware analysis
./launch.sh --help      # Show all options
```

## 📁 New Script Organization

All scripts are now organized by function:

```
scripts/
├── core/           # Container management
│   ├── start.sh    # Start container
│   ├── stop.sh     # Stop container
│   └── rebuild.sh  # Rebuild from scratch
│
├── desktop/        # Desktop environment
│   ├── launch-desktop.sh  # Launch desktop/apps
│   └── configure-menu.sh  # Fix menu issues
│
├── tools/          # Tool installation
│   ├── install-core.sh    # Essential tools
│   ├── install-full.sh    # All Kali tools
│   └── install-malware.sh # Malware analysis
│
├── malware/        # Malware analysis
│   ├── setup-lab.sh  # Setup isolated lab
│   └── analyze.sh    # Automated analysis
│
└── utils/          # Utilities
    ├── debug-menu.sh     # Diagnose issues
    ├── backup-config.sh  # Backup/restore
    └── setup-claude.sh   # Setup Claude CLI
```

## 🔧 Common Tasks

### Start Everything
```bash
./start.sh  # Simplest way
```

### Access Container Shell
```bash
docker exec -it kali-workspace /bin/zsh
```

### Install Tools
```bash
# From inside container or use launcher menu
/home/kali/scripts/tools/install-core.sh   # Quick essentials
/home/kali/scripts/tools/install-full.sh   # Everything
```

### Fix Menu Issues
```bash
# From launcher menu or directly:
docker exec -it kali-workspace /home/kali/scripts/desktop/configure-menu.sh
```

### Malware Analysis (Isolated)
```bash
./launch.sh --malware  # Sets up isolated environment
```

## 🎨 What Changed?

### Before (52 scripts, confusing)
- `kali-malware-analysis.sh` (1000+ lines)
- 26+ different menu fix scripts
- Unclear which script to use

### Now (15 scripts, organized)
- `./launch.sh` - Single entry point
- `./start.sh` - Quick desktop launch
- Clear categories in `scripts/` folder
- Each script has `--help`

## ⚡ Tips

1. **First time?** Just run `./start.sh`
2. **Need help?** Use `./launch.sh` for interactive menu
3. **Power user?** Use scripts directly from `scripts/` folders
4. **Issues?** Run diagnostics: `./launch.sh` → Configuration → Debug

## 🔍 Troubleshooting

### Container won't start
```bash
docker-compose down
./scripts/core/rebuild.sh
```

### Menu not working
```bash
./launch.sh  # Select: Configuration → Fix menu system
```

### Need to backup config
```bash
./launch.sh  # Select: Configuration → Backup configuration
```

## 📚 Full Documentation

- Architecture: `agentdocs/current-architecture-analysis.md`
- Implementation: `agentdocs/implementation-summary.md`
- Original docs: `docs/` folder

---

**Remember**: The old scripts still exist but are deprecated. Use the new unified launcher for the best experience!