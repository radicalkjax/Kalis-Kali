#!/bin/bash

echo "Claude Code Setup for Kali Linux Container"
echo "=========================================="
echo ""

# Check if user wants to use Max plan or API key
echo "How would you like to authenticate Claude Code?"
echo "1) Claude Max/Pro Plan (Recommended for Max plan users)"
echo "2) API Key"
echo ""
read -p "Select option (1 or 2): " AUTH_METHOD

if [ "$AUTH_METHOD" = "1" ]; then
    echo ""
    echo "[*] Setting up Claude Code with Max/Pro Plan authentication..."
    echo ""
    echo "This will open a browser window for authentication."
    echo "Make sure you have:"
    echo "  - A web browser available"
    echo "  - Your Claude account credentials ready"
    echo ""
    read -p "Press Enter to continue..."
    
    # Logout first to ensure clean state
    claude logout 2>/dev/null || true
    
    # Login with Max/Pro plan
    claude login
    
    echo ""
    echo "[+] Authentication complete!"
    echo ""
    echo "IMPORTANT: Make sure you authenticated with your Max/Pro plan account,"
    echo "not with API credentials, to avoid unexpected API charges."
    
elif [ "$AUTH_METHOD" = "2" ]; then
    # API key authentication
    if [ -n "$1" ]; then
        API_KEY="$1"
    elif [ -n "$ANTHROPIC_API_KEY" ]; then
        API_KEY="$ANTHROPIC_API_KEY"
    else
        echo ""
        echo "Please enter your Anthropic API key:"
        read -s API_KEY
        echo ""
    fi
    
    if [ -z "$API_KEY" ]; then
        echo "Error: No API key provided."
        exit 1
    fi
    
    # Configure Claude with API key
    echo "[*] Configuring Claude Code with API key..."
    claude auth set-api-key "$API_KEY"
    
else
    echo "Invalid option selected."
    exit 1
fi

# Test the configuration
echo ""
echo "[*] Testing Claude Code configuration..."
if claude --version > /dev/null 2>&1; then
    echo "[+] Claude Code is installed and configured successfully!"
    echo ""
    echo "Available commands:"
    echo "  claude chat              # Interactive chat"
    echo "  claude code             # Code-specific assistance"
    echo "  claude --help           # See all options"
    echo ""
    if [ "$AUTH_METHOD" = "1" ]; then
        echo "Max/Pro Plan features:"
        echo "  /model                  # Switch between models (Sonnet/Opus)"
        echo "  /logout                 # Logout from current session"
    fi
else
    echo "[-] Error: Claude Code configuration failed."
    exit 1
fi