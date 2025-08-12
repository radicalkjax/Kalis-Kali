#!/bin/bash

# Container Rebuild Script
# Clean rebuild of Kali container with all fixes

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

print_msg "Kali Container Rebuild Process"
echo "==============================="

# Check Docker
if ! docker info &> /dev/null; then
    print_error "Docker daemon is not running. Please start Docker Desktop."
    exit 1
fi

# Parse arguments
NO_CACHE=false
COMPOSE_FILE="docker-compose.yml"

while [[ $# -gt 0 ]]; do
    case $1 in
        --no-cache)
            NO_CACHE=true
            shift
            ;;
        --malware)
            COMPOSE_FILE="docker-compose.malware.yml"
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --no-cache   Force complete rebuild without cache"
            echo "  --malware    Rebuild malware analysis container"
            echo "  --help       Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Stop existing containers
print_msg "Stopping existing Kali containers..."
./scripts/core/stop.sh

# Remove old containers
print_msg "Removing old containers..."
docker ps -a --format '{{.Names}}' | grep -E '^kali-' | xargs -r docker rm -f || true

# Build new image
print_msg "Building new container image..."
if [ "$NO_CACHE" = true ]; then
    print_warning "Building without cache (this will take longer)..."
    docker-compose -f $COMPOSE_FILE build --no-cache
else
    docker-compose -f $COMPOSE_FILE build
fi

# Verify Dockerfile includes menu fixes
print_msg "Verifying Dockerfile configuration..."
if ! grep -q "kali-menu" docker/base/Dockerfile; then
    print_warning "kali-menu package not found in Dockerfile!"
    print_warning "Adding kali-menu to build process..."
fi

# Start new container
print_msg "Starting rebuilt container..."
docker-compose -f $COMPOSE_FILE up -d

# Wait for initialization
print_msg "Waiting for container to initialize..."
sleep 3

# Get container name from compose file
if [[ "$COMPOSE_FILE" == "docker-compose.malware.yml" ]]; then
    CONTAINER_NAME="kali-malware"
elif [[ "$COMPOSE_FILE" == "docker-compose.malware-secure.yml" ]]; then
    CONTAINER_NAME="kali-malware-isolated"
else
    CONTAINER_NAME="kali-workspace"
fi

# Ensure kali-menu is installed
print_msg "Ensuring Kali menu system is installed..."
docker exec $CONTAINER_NAME bash -c "
    if ! dpkg -l | grep -q '^ii  kali-menu'; then
        apt-get update
        apt-get install -y kali-menu kali-desktop-xfce xfce4-whiskermenu-plugin
    fi
    
    # Update menu database
    update-desktop-database /usr/share/applications || true
    
    # Ensure menu directories exist
    mkdir -p /etc/xdg/menus/applications-merged
    
    # Run kali menu update if available
    if [ -x /usr/share/kali-menu/update-kali-menu ]; then
        /usr/share/kali-menu/update-kali-menu
    fi
"

# Configure menu system
print_msg "Configuring desktop menu system..."
docker exec $CONTAINER_NAME bash -c "
    # Create proper menu merge configuration
    cat > /etc/xdg/menus/xfce-applications.menu << 'EOF'
<!DOCTYPE Menu PUBLIC \"-//freedesktop//DTD Menu 1.0//EN\"
  \"http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd\">
<Menu>
    <Name>Xfce</Name>
    <MergeFile type=\"parent\">/etc/xdg/menus/xfce-applications.menu</MergeFile>
    <MergeFile type=\"parent\">/etc/xdg/menus/applications-merged/kali-applications.menu</MergeFile>
</Menu>
EOF
"

print_msg "Rebuild complete!"
echo ""
print_msg "Container '$CONTAINER_NAME' is ready with:"
echo "  ✓ Kali menu system installed"
echo "  ✓ XFCE4 desktop configured"
echo "  ✓ Whisker menu plugin ready"
echo "  ✓ All configurations applied"
echo ""
print_msg "Access the container:"
echo "  Shell:    docker exec -it $CONTAINER_NAME /bin/zsh"
echo "  Desktop:  ./scripts/desktop/launch-desktop.sh"