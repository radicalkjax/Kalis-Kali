#!/bin/bash
# Simple fix for panel position

echo "Moving panel to left side..."

docker exec -u kali kali-workspace bash -c '
    # Kill panel
    xfce4-panel --quit 2>/dev/null || true
    sleep 1
    
    # Simple sed replacement to change position from right (p=3) to left (p=1)
    sed -i "s/value=\"p=3;/value=\"p=1;/g" ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
    
    # Also try with different position formats
    sed -i "s/\"p=3;x=/\"p=1;x=/g" ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
    sed -i "s/>p=3;/>p=1;/g" ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
    
    # Restart panel
    export DISPLAY=host.docker.internal:0
    xfce4-panel --disable-wm-check &
    
    sleep 2
    
    echo "Panel should now be on the LEFT side"
'

# Now add the malware tools using the panel preferences
echo ""
echo "To add malware analysis tools to the panel:"
echo "1. Right-click on the panel"
echo "2. Select Panel > Add New Items..."
echo "3. Add 'Launcher' items"
echo "4. Configure each launcher for:"
echo "   - Ghidra"
echo "   - Radare2" 
echo "   - Cutter"
echo "   - IDA Free"
echo "   - Volatility"
echo "   - YARA"