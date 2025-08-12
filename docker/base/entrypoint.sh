#!/bin/bash
# Custom entrypoint to ensure Kali menu is available

# Run menu check as root
if [ "$EUID" -eq 0 ] || [ "$(id -u)" = "0" ]; then
    /usr/local/bin/ensure-kali-menu.sh
else
    sudo /usr/local/bin/ensure-kali-menu.sh
fi

# Execute the original command
exec "$@"