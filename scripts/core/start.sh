#!/bin/bash

# Unified Kali Container Start Script
# Consolidates: start-kali.sh, start-proper-desktop.sh, start-malware-lab.sh, start-secure-malware-lab.sh

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
MODE="default"
REBUILD=false
COMPOSE_FILE="docker-compose.yml"
CONTAINER_NAME="kali-workspace"

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
    echo -e "${CYAN}[i]${NC} $1"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --malware)
            MODE="malware"
            COMPOSE_FILE="docker-compose.malware.yml"
            CONTAINER_NAME="kali-malware"
            shift
            ;;
        --isolated)
            MODE="isolated"
            COMPOSE_FILE="docker-compose.malware-secure.yml"
            CONTAINER_NAME="kali-malware-isolated"
            shift
            ;;
        --rebuild)
            REBUILD=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --malware    Start malware analysis container"
            echo "  --isolated   Start network-isolated malware container"
            echo "  --rebuild    Force rebuild container before starting"
            echo "  --help       Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                    # Start default Kali container"
            echo "  $0 --malware         # Start malware analysis environment"
            echo "  $0 --isolated        # Start isolated malware lab"
            echo "  $0 --rebuild         # Rebuild and start container"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

print_msg "Starting Kali Linux Container (Mode: $MODE)"
echo "================================================"

# Check Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker Desktop first."
    exit 1
fi

# Check if Docker is running, start if not
if ! docker info &> /dev/null; then
    print_warning "Docker daemon is not running"
    
    # Try to start Docker based on OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_msg "Starting Docker Desktop..."
        open -a Docker
        
        # Wait for Docker to be ready
        print_info "Waiting for Docker to start..."
        COUNTER=0
        MAX_WAIT=60
        
        while ! docker info &> /dev/null; do
            if [ $COUNTER -ge $MAX_WAIT ]; then
                print_error "Docker failed to start after ${MAX_WAIT} seconds"
                print_info "Please check Docker Desktop manually"
                exit 1
            fi
            
            # Show progress every 5 seconds
            if [ $((COUNTER % 5)) -eq 0 ] && [ $COUNTER -gt 0 ]; then
                echo "  Still waiting... ($COUNTER seconds)"
            fi
            
            sleep 1
            COUNTER=$((COUNTER + 1))
        done
        
        print_msg "Docker is ready!"
        sleep 2  # Give Docker a moment to fully initialize
        
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        print_msg "Attempting to start Docker service..."
        if command -v systemctl &> /dev/null; then
            if sudo systemctl start docker 2>/dev/null; then
                print_msg "Docker service started"
                sleep 2
            else
                print_error "Failed to start Docker service"
                print_info "Try: sudo systemctl start docker"
                exit 1
            fi
        elif command -v service &> /dev/null; then
            if sudo service docker start 2>/dev/null; then
                print_msg "Docker service started"
                sleep 2
            else
                print_error "Failed to start Docker service"
                print_info "Try: sudo service docker start"
                exit 1
            fi
        else
            print_error "Cannot start Docker automatically. Please start it manually."
            exit 1
        fi
    else
        print_error "Docker daemon is not running. Please start Docker Desktop."
        exit 1
    fi
fi

# Check XQuartz for GUI support
if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! command -v xquartz &> /dev/null && ! [ -d "/Applications/Utilities/XQuartz.app" ]; then
        print_warning "XQuartz not found. GUI applications will not work."
        print_warning "Install with: brew install --cask xquartz"
    else
        # Start XQuartz if not running
        if ! pgrep -x "XQuartz" > /dev/null; then
            print_msg "Starting XQuartz for GUI support..."
            open -a XQuartz
            sleep 2
        fi
        
        # Configure X11 permissions
        print_msg "Configuring X11 permissions..."
        xhost +localhost 2>/dev/null || true
    fi
fi

# Rebuild if requested
if [ "$REBUILD" = true ]; then
    print_msg "Rebuilding container image..."
    docker-compose -f $COMPOSE_FILE build --no-cache
fi

# Check if container exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    # Check if running
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        print_warning "Container $CONTAINER_NAME is already running"
        
        # Show container info
        echo ""
        print_msg "Container Information:"
        docker ps --filter "name=${CONTAINER_NAME}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        
        echo ""
        print_msg "To access the container:"
        echo "  CLI:  docker exec -it $CONTAINER_NAME /bin/zsh"
        echo "  GUI:  ./scripts/desktop/launch-desktop.sh"
    else
        print_msg "Starting existing container..."
        docker start $CONTAINER_NAME
        
        # Wait for container to be ready
        sleep 2
        
        print_msg "Container started successfully!"
    fi
else
    print_msg "Creating and starting new container..."
    docker-compose -f $COMPOSE_FILE up -d
    
    # Wait for container to be ready
    print_msg "Waiting for container to initialize..."
    sleep 3
    
    # Ensure kali-menu is installed (non-interactive)
    print_msg "Verifying Kali menu system..."
    docker exec $CONTAINER_NAME bash -c "
        if ! dpkg -l | grep -q '^ii  kali-menu'; then
            echo 'Installing Kali menu system...'
            apt-get update >/dev/null 2>&1
            apt-get install -y kali-menu kali-desktop-xfce >/dev/null 2>&1
        fi
    "
    
    # Ensure panel tools are installed (run as root in container)
    print_msg "Checking panel tools..."
    docker exec --user root $CONTAINER_NAME bash -c "
        # Quick check for critical panel tools
        MISSING=false
        for tool in cutter ghidra wireshark radare2; do
            if ! command -v \$tool >/dev/null 2>&1; then
                MISSING=true
                break
            fi
        done
        
        if [ \"\$MISSING\" = true ]; then
            echo 'Installing missing panel tools...'
            if [ -f /home/kali/scripts/utils/ensure-panel-tools.sh ]; then
                /home/kali/scripts/utils/ensure-panel-tools.sh >/dev/null 2>&1
            fi
        fi
    " 2>/dev/null || true
    
    print_msg "Container ready!"
fi

# Mode-specific setup
case $MODE in
    malware)
        print_msg "Malware analysis environment ready"
        print_warning "Remember: This container has network access. Use --isolated for network isolation."
        echo ""
        echo "Malware analysis tools available:"
        echo "  - YARA, Ghidra, Radare2, Rizin"
        echo "  - Volatility3, Wireshark, tcpdump"
        echo "  - oletools, pdf-parser, binwalk"
        echo ""
        echo "Run setup: docker exec -it $CONTAINER_NAME /home/kali/scripts/malware/setup-lab.sh"
        ;;
    isolated)
        print_msg "Isolated malware lab ready"
        print_warning "Network access is DISABLED for safety"
        echo ""
        echo "Sample directory: ./malware/samples/ (read-only in container)"
        echo "Reports directory: ./malware/reports/"
        echo ""
        echo "Verify isolation: docker exec $CONTAINER_NAME ping -c 1 8.8.8.8"
        echo "(This should fail if properly isolated)"
        ;;
    default)
        print_msg "Kali Linux container ready"
        ;;
esac

echo ""
print_msg "Quick Access Commands:"
echo "  Shell:    docker exec -it $CONTAINER_NAME /bin/zsh"
echo "  Desktop:  ./scripts/desktop/launch-desktop.sh"
echo "  Apps:     ./scripts/desktop/launch-app.sh [app-name]"
echo "  Stop:     ./scripts/core/stop.sh"

# Show workspace mount info
echo ""
print_msg "Persistent directories:"
echo "  Workspace: ./workspace → /home/kali/workspace"
echo "  Config:    ./config → /home/kali/.config"

# Check for Claude CLI setup
if docker exec $CONTAINER_NAME which claude >/dev/null 2>&1; then
    echo ""
    print_msg "Claude CLI is available. Use 'claude' command in container."
fi

echo ""
print_msg "Container '$CONTAINER_NAME' is ready for use!"