# Kali Linux Docker Container - Project Structure

## 📁 Directory Organization

```
Kalis-Kali/
│
├── 📄 README.md                    # Main project documentation
├── 📄 PROJECT-STRUCTURE.md         # This file - explains organization
├── 📄 .env.example                 # Environment variables template
├── 📄 .gitignore                   # Git ignore rules
│
├── 🐋 docker-compose.yml           # Main compose file for standard Kali
├── 🐋 docker-compose.malware.yml   # Malware analysis (INSECURE - learning only)
├── 🐋 docker-compose.malware-secure.yml  # Secure malware analysis
│
├── 📁 docker/                      # Docker configurations
│   ├── 📁 base/                    # Standard Kali container
│   │   ├── Dockerfile              # Main Kali image with GUI + tools
│   │   └── startup.sh              # Container startup script
│   │
│   └── 📁 malware/                 # Malware analysis containers
│       └── Dockerfile.malware-secure  # Minimal, hardened image
│
├── 📁 config/                      # Configuration files
│   ├── 📁 supervisor/              # Process management
│   │   └── supervisord.conf        # Process management configuration
│   └── 📁 x11/                     # X11 forwarding configs (if needed)
│
├── 📁 scripts/                     # Management and utility scripts
│   ├── start-kali.sh               # Start standard Kali container
│   ├── stop-kali.sh                # Stop Kali containers
│   ├── run-gui.sh                  # Run GUI apps with X11 forwarding
│   ├── setup-claude.sh             # Claude CLI configuration
│   ├── setup-tools.sh              # Install additional tools
│   ├── setup-malware-analysis.sh   # Malware analysis environment setup
│   ├── start-malware-lab.sh        # Start insecure malware lab (learning)
│   ├── start-secure-malware-lab.sh # Start SECURE malware lab
│   └── safe-analyze.sh             # Safe malware analysis script
│
├── 📁 docs/                        # Documentation
│   ├── SECURITY-WARNING.md         # Critical security information
│   └── TOOLS.md                    # Complete tool inventory
│
├── 📁 workspace/                   # Persistent general workspace
│
└── 📁 malware/                     # Malware analysis directories
    ├── 📁 samples/                 # Malware samples (read-only in container)
    ├── 📁 reports/                 # Analysis reports output
    ├── 📁 captures/                # Network captures
    └── 📁 sandbox-output/          # Sandbox execution results
```

## 🚀 Quick Start Commands

### Standard Kali Container
```bash
./scripts/start-kali.sh             # Start with GUI support
docker exec -it kali-workspace /bin/bash  # Access CLI
# GUI apps run as native macOS windows via X11
```

### Secure Malware Analysis
```bash
./scripts/start-secure-malware-lab.sh  # Choose security level
docker exec -it kali-malware-static /bin/bash  # Access container
```

## 🔧 Configuration Files

### Docker Compose Files
- `docker-compose.yml` - Standard Kali with full tools
- `docker-compose.malware.yml` - Legacy malware setup (insecure)
- `docker-compose.malware-secure.yml` - Secure 3-tier malware analysis

### Environment Variables
Copy `.env.example` to `.env` and configure:
- `ANTHROPIC_API_KEY` - For Claude CLI (API users)
- `CLAUDE_AUTH_METHOD` - Set to "max" for Max plan users

## 📦 Container Types

### 1. Standard Kali (`kali-workspace`)
- Full Kali tools + GUI
- Development environment
- Claude CLI integrated
- Network access enabled

### 2. Malware Analysis (Secure)
- **Static Analysis** - No network, read-only, safest
- **Dynamic Analysis** - Isolated network, monitoring
- **Sandbox** - Honeypot network, auto-cleanup

## 🛡️ Security Notes

- Standard container uses `privileged: true` for certain tools
- Malware containers use defense-in-depth security
- Always use secure containers for real malware
- See `docs/SECURITY-WARNING.md` for critical info

## 🔄 Workflow

1. **General Security Work**: Use standard Kali container
2. **Malware Analysis**: Use secure malware containers
3. **Development**: Mount code in `/workspace`
4. **Reports**: Generated in appropriate directories

## 📝 Maintenance

- Pull latest base: `docker pull kalilinux/kali-rolling:latest`
- Rebuild: `docker-compose build --no-cache`
- Clean up: `docker system prune -a`