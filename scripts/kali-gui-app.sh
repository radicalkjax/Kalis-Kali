#!/bin/bash
# Launch individual GUI applications from Kali container

# Check if app name provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <application-name> [arguments]"
    echo ""
    echo "Examples:"
    echo "  $0 firefox-esr"
    echo "  $0 xfce4-terminal"
    echo "  $0 gedit"
    echo "  $0 wireshark"
    echo ""
    exit 1
fi

# Check if container is running
if ! docker ps | grep -q kali-workspace; then
    echo "Error: kali-workspace container is not running"
    echo "Start it with: docker-compose up -d kali"
    exit 1
fi

# Check if socat is running
if ! pgrep -f "socat.*6000" > /dev/null; then
    echo "Starting X11 bridge..."
    nohup socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:"/tmp/.X11-unix/X0" > /tmp/socat-x11.log 2>&1 &
    sleep 1
fi

# Launch the application
APP_NAME=$1
shift
APP_ARGS=$@

echo "Launching $APP_NAME..."
docker exec -it kali-workspace sh -c "DISPLAY=host.docker.internal:0 dbus-launch $APP_NAME $APP_ARGS"