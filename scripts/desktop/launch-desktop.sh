#!/bin/bash

# Unified Desktop/Application Launcher
# Consolidates: kali-desktop.sh, kali-gui-app.sh, run-gui.sh, x11-docker.sh

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
CONTAINER_NAME="kali-workspace"
APP=""
MODE="desktop"
MINIMAL=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --app)
            MODE="app"
            APP="$2"
            shift 2
            ;;
        --minimal)
            MINIMAL=true
            shift
            ;;
        --container)
            CONTAINER_NAME="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --app NAME       Launch specific application"
            echo "  --minimal        Launch minimal desktop (no extras)"
            echo "  --container NAME Use specific container (default: kali-workspace)"
            echo "  --help           Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                           # Full XFCE4 desktop"
            echo "  $0 --minimal                # Minimal desktop"
            echo "  $0 --app firefox            # Launch Firefox only"
            echo "  $0 --app burpsuite          # Launch Burp Suite"
            echo "  $0 --app wireshark          # Launch Wireshark"
            echo "  $0 --app ghidra             # Launch Ghidra"
            echo ""
            echo "Common applications:"
            echo "  firefox, burpsuite, wireshark, ghidra, metasploit"
            echo "  nmap, sqlmap, john, hashcat, gobuster, nikto"
            echo "  terminal, thunar, mousepad, gedit"
            exit 0
            ;;
        *)
            # If no flag, assume it's an app name
            if [ -z "$APP" ] && [ "$MODE" == "desktop" ]; then
                MODE="app"
                APP="$1"
            else
                print_error "Unknown option: $1"
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    print_error "Container '$CONTAINER_NAME' is not running"
    print_msg "Start it with: ./scripts/core/start.sh"
    exit 1
fi

# macOS X11 setup
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Check XQuartz
    if ! [ -d "/Applications/Utilities/XQuartz.app" ]; then
        print_error "XQuartz is not installed!"
        print_msg "Install with: brew install --cask xquartz"
        exit 1
    fi
    
    # Start XQuartz if needed
    if ! pgrep -x "XQuartz" > /dev/null; then
        print_msg "Starting XQuartz..."
        open -a XQuartz
        sleep 2
    fi
    
    # Configure XQuartz settings
    print_msg "Configuring XQuartz..."
    defaults write org.xquartz.X11 nolisten_tcp -bool false
    defaults write org.xquartz.X11 no_auth -bool false
    defaults write org.xquartz.X11 enable_iglx -bool true
    
    # Set X11 permissions
    export DISPLAY=:0
    xhost +localhost >/dev/null 2>&1
    
    # Check for socat bridge (needed for container X11)
    if ! pgrep -f "socat.*6000" > /dev/null; then
        print_msg "Starting X11 bridge..."
        nohup socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:"/tmp/.X11-unix/X0" > /tmp/socat-x11.log 2>&1 &
        sleep 1
    fi
fi

# Launch based on mode
case $MODE in
    desktop)
        if [ "$MINIMAL" = true ]; then
            print_msg "Launching minimal XFCE4 desktop..."
            if [ -t 0 ]; then
                docker exec -it -e DISPLAY=host.docker.internal:0 \
                    -e XAUTHORITY=/home/kali/.Xauthority \
                    --user kali \
                    $CONTAINER_NAME \
                    bash -c "startxfce4 --replace"
            else
                docker exec -d -e DISPLAY=host.docker.internal:0 \
                    -e XAUTHORITY=/home/kali/.Xauthority \
                    --user kali \
                    $CONTAINER_NAME \
                    bash -c "startxfce4 --replace" 2>/dev/null
                print_msg "Minimal desktop launched in background"
            fi
        else
            print_msg "Launching full XFCE4 desktop..."
            
            # Ensure desktop packages are installed
            docker exec $CONTAINER_NAME bash -c "
                pkgs='xfce4-session xfce4-panel xfce4-terminal xfdesktop4 xfwm4 
                      xfce4-settings xfce4-whiskermenu-plugin thunar
                      xfce4-power-manager xfce4-screenshooter'
                
                missing=''
                for pkg in \$pkgs; do
                    if ! dpkg -l | grep -q \"^ii  \$pkg\"; then
                        missing=\"\$missing \$pkg\"
                    fi
                done
                
                if [ -n \"\$missing\" ]; then
                    echo 'Installing missing desktop components...'
                    apt-get update >/dev/null 2>&1
                    apt-get install -y \$missing >/dev/null 2>&1
                fi
            " 2>/dev/null
            
            # Configure and launch
            print_msg "Configuring desktop environment..."
            docker exec $CONTAINER_NAME bash -c "
                # Ensure directories exist
                mkdir -p /home/kali/.config/xfce4/panel
                mkdir -p /home/kali/.config/xfce4/xfconf/xfce-perchannel-xml
                
                # Set proper permissions
                chown -R kali:kali /home/kali/.config
                
                # Configure menu system
                /home/kali/scripts/desktop/configure-menu.sh 2>/dev/null || true
            " 2>/dev/null
            
            # Launch desktop
            # Check if we have a TTY
            if [ -t 0 ]; then
                # Interactive mode
                docker exec -it -e DISPLAY=host.docker.internal:0 \
                    -e XAUTHORITY=/home/kali/.Xauthority \
                    --user kali \
                    $CONTAINER_NAME \
                    bash -c "
                        # Configure session
                        export XDG_SESSION_TYPE=x11
                        export XDG_CURRENT_DESKTOP=XFCE
                        export XDG_CONFIG_HOME=/home/kali/.config
                        export XDG_DATA_HOME=/home/kali/.local/share
                        
                        # Start dbus if needed
                        if ! pgrep -x 'dbus-daemon' > /dev/null; then
                            eval \$(dbus-launch --sh-syntax)
                        fi
                        
                        # Launch desktop
                        startxfce4
                    "
            else
                # Non-interactive mode (detached)
                docker exec -d -e DISPLAY=host.docker.internal:0 \
                    -e XAUTHORITY=/home/kali/.Xauthority \
                    --user kali \
                    $CONTAINER_NAME \
                    bash -c "
                        # Configure session
                        export XDG_SESSION_TYPE=x11
                        export XDG_CURRENT_DESKTOP=XFCE
                        export XDG_CONFIG_HOME=/home/kali/.config
                        export XDG_DATA_HOME=/home/kali/.local/share
                        
                        # Start dbus if needed
                        if ! pgrep -x 'dbus-daemon' > /dev/null; then
                            eval \$(dbus-launch --sh-syntax)
                        fi
                        
                        # Launch desktop
                        startxfce4
                    " 2>/dev/null
                print_msg "Desktop launched in background mode"
                print_info "The desktop should appear in a few seconds"
            fi
        fi
        
        print_msg "Desktop environment launched!"
        print_warning "Close the desktop window to return to terminal"
        ;;
        
    app)
        if [ -z "$APP" ]; then
            print_error "No application specified!"
            echo "Use: $0 --app [application-name]"
            exit 1
        fi
        
        print_msg "Launching $APP..."
        
        # Check if app exists
        if ! docker exec $CONTAINER_NAME which $APP >/dev/null 2>&1; then
            print_warning "$APP not found, attempting to install..."
            
            # Try to install the app
            docker exec $CONTAINER_NAME bash -c "
                apt-get update >/dev/null 2>&1
                apt-get install -y $APP >/dev/null 2>&1
            " || {
                print_error "Failed to install $APP"
                print_msg "Try installing manually: docker exec -it $CONTAINER_NAME apt-get install $APP"
                exit 1
            }
        fi
        
        # Launch the application
        docker exec -d \
            -e DISPLAY=host.docker.internal:0 \
            -e XAUTHORITY=/home/kali/.Xauthority \
            --user kali \
            $CONTAINER_NAME \
            $APP 2>/dev/null
        
        print_msg "$APP launched successfully!"
        print_msg "The application is running in the background"
        ;;
esac

# Show helpful commands
echo ""
print_msg "Useful commands:"
echo "  Launch another app:  $0 --app [name]"
echo "  List GUI apps:       docker exec $CONTAINER_NAME ls /usr/share/applications/"
echo "  Stop container:      ./scripts/core/stop.sh"