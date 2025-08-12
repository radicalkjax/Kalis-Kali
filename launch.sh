#!/bin/bash

# Unified Kali Container Launcher
# Simple entry point for all use cases

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

print_title() {
    echo -e "${CYAN}$1${NC}"
}

# Show banner
clear
print_title "╔════════════════════════════════════════════╗"
print_title "║        Kali Linux Container Launcher       ║"
print_title "╚════════════════════════════════════════════╝"
echo ""

# Parse arguments for quick launch
QUICK_MODE=""
SKIP_MENU=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --shell|-s)
            QUICK_MODE="shell"
            SKIP_MENU=true
            shift
            ;;
        --desktop|-d)
            QUICK_MODE="desktop"
            SKIP_MENU=true
            shift
            ;;
        --malware|-m)
            QUICK_MODE="malware"
            SKIP_MENU=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Quick launch options:"
            echo "  -s, --shell     Launch shell directly"
            echo "  -d, --desktop   Launch desktop directly"
            echo "  -m, --malware   Launch malware analysis environment"
            echo "  -h, --help      Show this help message"
            echo ""
            echo "Without options, shows interactive menu"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Check if Docker is running, start if not
if ! docker info &> /dev/null; then
    print_warning "Docker is not running"
    
    # Check OS and start Docker accordingly
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - start Docker Desktop
        print_msg "Starting Docker Desktop..."
        open -a Docker
        
        # Wait for Docker to be ready
        print_info "Waiting for Docker to start..."
        COUNTER=0
        MAX_WAIT=60  # Maximum 60 seconds
        
        while ! docker info &> /dev/null; do
            if [ $COUNTER -ge $MAX_WAIT ]; then
                print_error "Docker failed to start after ${MAX_WAIT} seconds"
                print_info "Please check Docker Desktop and try again"
                exit 1
            fi
            
            # Show progress
            if [ $((COUNTER % 5)) -eq 0 ]; then
                echo -n "."
            fi
            
            sleep 1
            COUNTER=$((COUNTER + 1))
        done
        echo ""
        print_msg "Docker is ready!"
        
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux - try to start docker service
        print_msg "Attempting to start Docker service..."
        if command -v systemctl &> /dev/null; then
            sudo systemctl start docker 2>/dev/null || {
                print_error "Failed to start Docker service"
                print_info "Try: sudo systemctl start docker"
                exit 1
            }
        else
            print_error "Please start Docker manually"
            exit 1
        fi
    else
        print_error "Unsupported OS: $OSTYPE"
        print_info "Please start Docker manually"
        exit 1
    fi
    
    # Brief pause to ensure Docker is fully ready
    sleep 2
fi

# Check if container is running
container_running() {
    docker ps --format '{{.Names}}' | grep -q "^kali-workspace$"
}

# Function to ensure container is started
ensure_container() {
    if ! container_running; then
        print_warning "Container not running. Starting..."
        ./scripts/core/start.sh
        sleep 2
    else
        print_msg "Container is running"
    fi
}

# Function to launch shell
launch_shell() {
    ensure_container
    print_msg "Launching shell..."
    echo ""
    docker exec -it kali-workspace /bin/zsh
}

# Function to launch desktop
launch_desktop() {
    ensure_container
    print_msg "Launching desktop environment..."
    ./scripts/desktop/launch-desktop.sh
}

# Function to launch malware analysis
launch_malware() {
    print_msg "Starting malware analysis environment..."
    
    # Stop existing container and start with isolation
    ./scripts/core/stop.sh 2>/dev/null || true
    ./scripts/core/start.sh --isolated
    
    # Setup malware lab
    print_info "Setting up malware analysis lab..."
    docker exec kali-malware-isolated /home/kali/scripts/malware/setup-lab.sh
    
    # Launch desktop
    print_msg "Launching isolated desktop..."
    ./scripts/desktop/launch-desktop.sh --container kali-malware-isolated
}

# Function to show tools menu
show_tools_menu() {
    echo ""
    print_title "Tool Installation Options:"
    echo "  1) Install core tools only"
    echo "  2) Install full Kali toolset"
    echo "  3) Install malware analysis tools"
    echo "  4) Back to main menu"
    echo ""
    read -p "Select option (1-4): " tools_choice
    
    case $tools_choice in
        1)
            ensure_container
            print_msg "Installing core tools..."
            docker exec -it kali-workspace /home/kali/scripts/tools/install-core.sh
            ;;
        2)
            ensure_container
            print_msg "Installing full toolset (this will take time)..."
            docker exec -it kali-workspace /home/kali/scripts/tools/install-full.sh
            ;;
        3)
            ensure_container
            print_msg "Installing malware analysis tools..."
            docker exec -it kali-workspace /home/kali/scripts/tools/install-malware.sh
            ;;
        4)
            return
            ;;
        *)
            print_error "Invalid choice"
            ;;
    esac
}

# Function to show configuration menu
show_config_menu() {
    echo ""
    print_title "Configuration Options:"
    echo "  1) Fix menu system"
    echo "  2) Debug menu issues"
    echo "  3) Backup configuration"
    echo "  4) Restore configuration"
    echo "  5) Setup Claude CLI"
    echo "  6) Back to main menu"
    echo ""
    read -p "Select option (1-6): " config_choice
    
    case $config_choice in
        1)
            ensure_container
            print_msg "Fixing menu system..."
            docker exec -it kali-workspace /home/kali/scripts/desktop/configure-menu.sh
            ;;
        2)
            ensure_container
            print_msg "Running menu diagnostics..."
            docker exec -it kali-workspace /home/kali/scripts/utils/debug-menu.sh
            ;;
        3)
            ensure_container
            print_msg "Backing up configuration..."
            docker exec -it kali-workspace /home/kali/scripts/utils/backup-config.sh
            ;;
        4)
            ensure_container
            print_info "Available backups:"
            docker exec kali-workspace ls -la /home/kali/backups/*.tar.gz 2>/dev/null || echo "No backups found"
            echo ""
            read -p "Enter backup filename: " backup_file
            if [ -n "$backup_file" ]; then
                docker exec -it kali-workspace /home/kali/scripts/utils/backup-config.sh -r "$backup_file"
            fi
            ;;
        5)
            ensure_container
            print_msg "Setting up Claude CLI..."
            docker exec -it kali-workspace /home/kali/scripts/utils/setup-claude.sh
            ;;
        6)
            return
            ;;
        *)
            print_error "Invalid choice"
            ;;
    esac
}

# Function to show container menu
show_container_menu() {
    echo ""
    print_title "Container Management:"
    echo "  1) Start container"
    echo "  2) Stop container"
    echo "  3) Restart container"
    echo "  4) Rebuild container"
    echo "  5) Container status"
    echo "  6) Back to main menu"
    echo ""
    read -p "Select option (1-6): " container_choice
    
    case $container_choice in
        1)
            print_msg "Starting container..."
            ./scripts/core/start.sh
            ;;
        2)
            print_msg "Stopping container..."
            ./scripts/core/stop.sh
            ;;
        3)
            print_msg "Restarting container..."
            ./scripts/core/stop.sh
            sleep 2
            ./scripts/core/start.sh
            ;;
        4)
            print_msg "Rebuilding container..."
            ./scripts/core/rebuild.sh
            ;;
        5)
            print_info "Container Status:"
            if container_running; then
                print_msg "Container is running"
                docker ps --filter "name=kali" --format "table {{.Names}}\t{{.Status}}\t{{.Size}}"
            else
                print_warning "Container is not running"
                docker ps -a --filter "name=kali" --format "table {{.Names}}\t{{.Status}}\t{{.Size}}"
            fi
            ;;
        6)
            return
            ;;
        *)
            print_error "Invalid choice"
            ;;
    esac
}

# Quick mode execution
if [ "$SKIP_MENU" = true ]; then
    case $QUICK_MODE in
        shell)
            launch_shell
            ;;
        desktop)
            launch_desktop
            ;;
        malware)
            launch_malware
            ;;
    esac
    exit 0
fi

# Main menu loop
while true; do
    echo ""
    print_title "Main Menu:"
    echo "  1) Launch Shell"
    echo "  2) Launch Desktop"
    echo "  3) Launch Malware Analysis (Isolated)"
    echo "  4) Install Tools"
    echo "  5) Configuration"
    echo "  6) Container Management"
    echo "  7) Exit"
    echo ""
    
    # Show container status
    if container_running; then
        print_info "Status: Container running ✓"
    else
        print_warning "Status: Container not running"
    fi
    echo ""
    
    read -p "Select option (1-7): " choice
    
    case $choice in
        1)
            launch_shell
            ;;
        2)
            launch_desktop
            ;;
        3)
            launch_malware
            ;;
        4)
            show_tools_menu
            ;;
        5)
            show_config_menu
            ;;
        6)
            show_container_menu
            ;;
        7)
            print_msg "Goodbye!"
            exit 0
            ;;
        *)
            print_error "Invalid choice. Please select 1-7"
            ;;
    esac
    
    # Pause before showing menu again
    echo ""
    read -p "Press Enter to continue..."
done