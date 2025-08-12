#!/bin/bash

# Configuration Backup Utility
# Backs up all XFCE and Kali configurations

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_msg() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_error() {
    echo -e "${RED}[!]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[*]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

# Default values
BACKUP_DIR=""
RESTORE=false
ARCHIVE_NAME=""
LIST_ONLY=false

# Usage function
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Backup and restore Kali/XFCE configurations"
    echo ""
    echo "Options:"
    echo "  -b DIR     Backup to directory (default: ~/backups)"
    echo "  -r FILE    Restore from backup archive"
    echo "  -l         List available backups"
    echo "  -h         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Create backup with timestamp"
    echo "  $0 -b /tmp           # Backup to /tmp directory"
    echo "  $0 -r backup.tar.gz  # Restore from archive"
    echo "  $0 -l                # List all backups"
}

# Parse arguments
while getopts "b:r:lh" opt; do
    case $opt in
        b)
            BACKUP_DIR="$OPTARG"
            ;;
        r)
            RESTORE=true
            ARCHIVE_NAME="$OPTARG"
            ;;
        l)
            LIST_ONLY=true
            ;;
        h)
            show_usage
            exit 0
            ;;
        \?)
            print_error "Invalid option: -$OPTARG"
            show_usage
            exit 1
            ;;
    esac
done

# Set default backup directory
if [ -z "$BACKUP_DIR" ]; then
    BACKUP_DIR="$HOME/backups"
fi

# List backups if requested
if [ "$LIST_ONLY" = true ]; then
    print_info "Available backups in $BACKUP_DIR:"
    if [ -d "$BACKUP_DIR" ]; then
        ls -lah "$BACKUP_DIR"/kali-config-*.tar.gz 2>/dev/null || echo "No backups found"
    else
        echo "Backup directory does not exist"
    fi
    exit 0
fi

# ============================================================================
# RESTORE MODE
# ============================================================================

if [ "$RESTORE" = true ]; then
    if [ -z "$ARCHIVE_NAME" ]; then
        print_error "No backup file specified!"
        exit 1
    fi
    
    if [ ! -f "$ARCHIVE_NAME" ]; then
        print_error "Backup file not found: $ARCHIVE_NAME"
        exit 1
    fi
    
    print_msg "Restoring configuration from: $ARCHIVE_NAME"
    print_warning "This will overwrite current configuration!"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_msg "Restore cancelled"
        exit 0
    fi
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT
    
    # Extract archive
    print_info "Extracting backup..."
    tar -xzf "$ARCHIVE_NAME" -C "$TEMP_DIR"
    
    # Check backup structure
    if [ ! -d "$TEMP_DIR/config-backup" ]; then
        print_error "Invalid backup archive structure"
        exit 1
    fi
    
    # Stop XFCE panel if running
    if pgrep -x "xfce4-panel" > /dev/null; then
        print_info "Stopping XFCE panel..."
        xfce4-panel --quit 2>/dev/null || true
    fi
    
    # Restore configurations
    print_info "Restoring XFCE configuration..."
    if [ -d "$TEMP_DIR/config-backup/xfce4" ]; then
        rm -rf ~/.config/xfce4
        cp -r "$TEMP_DIR/config-backup/xfce4" ~/.config/
    fi
    
    print_info "Restoring menu configuration..."
    if [ -d "$TEMP_DIR/config-backup/menus" ]; then
        rm -rf ~/.config/menus
        cp -r "$TEMP_DIR/config-backup/menus" ~/.config/
    fi
    
    print_info "Restoring Thunar configuration..."
    if [ -d "$TEMP_DIR/config-backup/Thunar" ]; then
        rm -rf ~/.config/Thunar
        cp -r "$TEMP_DIR/config-backup/Thunar" ~/.config/
    fi
    
    # Restore system menu files if running as root
    if [ "$EUID" -eq 0 ]; then
        if [ -f "$TEMP_DIR/config-backup/system/xfce-applications.menu" ]; then
            print_info "Restoring system menu configuration..."
            cp "$TEMP_DIR/config-backup/system/xfce-applications.menu" /etc/xdg/menus/
        fi
    fi
    
    # Set proper permissions
    chown -R $(whoami):$(whoami) ~/.config
    
    # Restart panel if it was running
    if [ -n "$(pgrep -x xfce4-session)" ]; then
        print_info "Restarting XFCE panel..."
        xfce4-panel & disown
    fi
    
    print_msg "Configuration restored successfully!"
    print_info "You may need to logout and login for all changes to take effect"
    exit 0
fi

# ============================================================================
# BACKUP MODE
# ============================================================================

print_msg "Creating configuration backup"
echo "============================="

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Generate backup filename
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/kali-config-${TIMESTAMP}.tar.gz"
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Create backup structure
BACKUP_ROOT="$TEMP_DIR/config-backup"
mkdir -p "$BACKUP_ROOT"

# Configurations to backup
print_info "Collecting configuration files..."

# XFCE4 configuration
if [ -d ~/.config/xfce4 ]; then
    print_info "  • XFCE4 configuration"
    cp -r ~/.config/xfce4 "$BACKUP_ROOT/"
fi

# Menu configuration
if [ -d ~/.config/menus ]; then
    print_info "  • Menu configuration"
    cp -r ~/.config/menus "$BACKUP_ROOT/"
fi

# Thunar configuration
if [ -d ~/.config/Thunar ]; then
    print_info "  • Thunar configuration"
    cp -r ~/.config/Thunar "$BACKUP_ROOT/"
fi

# Terminal configuration
if [ -d ~/.config/xfce4-terminal ]; then
    print_info "  • Terminal configuration"
    cp -r ~/.config/xfce4-terminal "$BACKUP_ROOT/"
fi

# GTK settings
if [ -d ~/.config/gtk-3.0 ]; then
    print_info "  • GTK3 configuration"
    cp -r ~/.config/gtk-3.0 "$BACKUP_ROOT/"
fi

# User directories
if [ -f ~/.config/user-dirs.dirs ]; then
    print_info "  • User directories"
    cp ~/.config/user-dirs.dirs "$BACKUP_ROOT/"
fi

# Shell configurations
if [ -f ~/.zshrc ]; then
    print_info "  • ZSH configuration"
    cp ~/.zshrc "$BACKUP_ROOT/"
fi

if [ -f ~/.bashrc ]; then
    print_info "  • Bash configuration"
    cp ~/.bashrc "$BACKUP_ROOT/"
fi

# System menu files (if accessible)
mkdir -p "$BACKUP_ROOT/system"
if [ -f /etc/xdg/menus/xfce-applications.menu ]; then
    print_info "  • System menu configuration"
    cp /etc/xdg/menus/xfce-applications.menu "$BACKUP_ROOT/system/" 2>/dev/null || true
fi

# Create backup information file
cat > "$BACKUP_ROOT/backup-info.txt" << EOF
Kali Configuration Backup
=========================
Date: $(date)
User: $(whoami)
Hostname: $(hostname)
System: $(lsb_release -d 2>/dev/null | cut -f2 || echo "Unknown")

Included configurations:
$(ls -1 "$BACKUP_ROOT" | grep -v backup-info.txt | sed 's/^/  - /')

To restore this backup:
  $0 -r $BACKUP_FILE
EOF

# Create archive
print_info "Creating backup archive..."
cd "$TEMP_DIR"
tar -czf "$BACKUP_FILE" config-backup

# Calculate backup size
BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)

# Generate verification
print_info "Generating verification hash..."
BACKUP_HASH=$(sha256sum "$BACKUP_FILE" | cut -d' ' -f1)
echo "$BACKUP_HASH  $(basename "$BACKUP_FILE")" > "$BACKUP_FILE.sha256"

# Create restore script
RESTORE_SCRIPT="$BACKUP_DIR/restore-${TIMESTAMP}.sh"
cat > "$RESTORE_SCRIPT" << EOF
#!/bin/bash
# Auto-generated restore script for backup $TIMESTAMP
# SHA256: $BACKUP_HASH

echo "Restoring configuration from: $(basename "$BACKUP_FILE")"
echo "Backup date: $(date)"
echo ""

# Verify backup integrity
echo "Verifying backup integrity..."
expected="$BACKUP_HASH"
actual=\$(sha256sum "$BACKUP_FILE" | cut -d' ' -f1)

if [ "\$expected" != "\$actual" ]; then
    echo "ERROR: Backup file has been modified!"
    echo "Expected: \$expected"
    echo "Actual:   \$actual"
    exit 1
fi

echo "Integrity check passed!"
echo ""

# Run restore
$0 -r "$BACKUP_FILE"
EOF
chmod +x "$RESTORE_SCRIPT"

# Summary
echo ""
echo "======================================"
print_msg "Backup Complete!"
echo "======================================"
echo ""
print_info "Backup Details:"
echo "  File:     $BACKUP_FILE"
echo "  Size:     $BACKUP_SIZE"
echo "  SHA256:   ${BACKUP_HASH:0:16}..."
echo ""
print_info "Quick restore:"
echo "  $0 -r $BACKUP_FILE"
echo ""
print_info "Or use the generated script:"
echo "  $RESTORE_SCRIPT"
echo ""

# List recent backups
print_info "Recent backups:"
ls -lah "$BACKUP_DIR"/kali-config-*.tar.gz | tail -5