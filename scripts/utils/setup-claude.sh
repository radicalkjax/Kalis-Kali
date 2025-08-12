#!/bin/bash

# Claude CLI Setup Utility
# Configure Claude Code in Kali container

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

echo "======================================"
echo "     Claude Code Setup Utility        "
echo "======================================"
echo ""

# Check if Claude is installed
if ! command -v claude &> /dev/null; then
    print_error "Claude Code is not installed!"
    print_info "Installing Claude Code..."
    
    if command -v npm &> /dev/null; then
        npm install -g @anthropic-ai/claude-code
    else
        print_error "npm is not installed. Cannot install Claude Code."
        print_info "Install npm first: apt-get install nodejs npm"
        exit 1
    fi
fi

print_msg "Claude Code is installed at: $(which claude)"
echo ""

# Check current authentication status
print_info "Checking current authentication status..."
if claude --version &>/dev/null; then
    # Try to check if already authenticated
    if claude list 2>&1 | grep -q "Unauthorized"; then
        print_warning "Not authenticated"
    else
        print_msg "Claude appears to be configured"
        echo ""
        read -p "Do you want to reconfigure? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_msg "Keeping current configuration"
            exit 0
        fi
    fi
fi

echo ""
print_info "Authentication Options:"
echo "  1) Claude Max/Pro Plan (Recommended for Max/Pro users)"
echo "  2) API Key"
echo "  3) Skip configuration"
echo ""
read -p "Select option (1-3): " AUTH_METHOD

case $AUTH_METHOD in
    1)
        # Max/Pro Plan authentication
        print_msg "Setting up Claude Code with Max/Pro Plan authentication..."
        echo ""
        print_info "This will open a browser window for authentication."
        print_info "Make sure you have:"
        echo "  • A web browser available"
        echo "  • Your Claude account credentials ready"
        echo ""
        read -p "Press Enter to continue..."
        
        # Logout first to ensure clean state
        print_info "Clearing any existing authentication..."
        claude logout 2>/dev/null || true
        
        # Login with Max/Pro plan
        print_msg "Opening browser for authentication..."
        claude login
        
        if [ $? -eq 0 ]; then
            echo ""
            print_msg "Authentication successful!"
            echo ""
            print_warning "IMPORTANT: Make sure you authenticated with your Max/Pro plan account,"
            print_warning "not with API credentials, to avoid unexpected API charges."
        else
            print_error "Authentication failed!"
            exit 1
        fi
        ;;
        
    2)
        # API key authentication
        print_msg "Setting up Claude Code with API key..."
        echo ""
        
        # Check for existing API key
        if [ -n "$ANTHROPIC_API_KEY" ]; then
            print_info "Found API key in environment variable"
            read -p "Use existing key? (Y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Nn]$ ]]; then
                ANTHROPIC_API_KEY=""
            fi
        fi
        
        if [ -z "$ANTHROPIC_API_KEY" ]; then
            print_info "Please enter your Anthropic API key:"
            read -s API_KEY
            echo ""
        else
            API_KEY="$ANTHROPIC_API_KEY"
        fi
        
        if [ -z "$API_KEY" ]; then
            print_error "No API key provided!"
            exit 1
        fi
        
        # Validate API key format
        if [[ ! "$API_KEY" =~ ^sk-ant-api[0-9]{2}-[a-zA-Z0-9_-]+$ ]]; then
            print_warning "API key format looks unusual, but continuing..."
        fi
        
        # Set API key
        print_info "Configuring Claude with API key..."
        export ANTHROPIC_API_KEY="$API_KEY"
        
        # Save to shell config
        echo ""
        read -p "Save API key to shell configuration? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Add to .zshrc if using zsh
            if [ -f ~/.zshrc ]; then
                if ! grep -q "ANTHROPIC_API_KEY" ~/.zshrc; then
                    echo "" >> ~/.zshrc
                    echo "# Claude Code API Key" >> ~/.zshrc
                    echo "export ANTHROPIC_API_KEY='$API_KEY'" >> ~/.zshrc
                    print_msg "API key saved to ~/.zshrc"
                else
                    print_info "API key already in ~/.zshrc, updating..."
                    sed -i "s/export ANTHROPIC_API_KEY=.*/export ANTHROPIC_API_KEY='$API_KEY'/" ~/.zshrc
                fi
            fi
            
            # Add to .bashrc if using bash
            if [ -f ~/.bashrc ]; then
                if ! grep -q "ANTHROPIC_API_KEY" ~/.bashrc; then
                    echo "" >> ~/.bashrc
                    echo "# Claude Code API Key" >> ~/.bashrc
                    echo "export ANTHROPIC_API_KEY='$API_KEY'" >> ~/.bashrc
                    print_msg "API key saved to ~/.bashrc"
                else
                    print_info "API key already in ~/.bashrc, updating..."
                    sed -i "s/export ANTHROPIC_API_KEY=.*/export ANTHROPIC_API_KEY='$API_KEY'/" ~/.bashrc
                fi
            fi
        fi
        
        print_msg "API key configuration complete!"
        print_warning "Note: API usage will be charged to your account"
        ;;
        
    3)
        print_msg "Skipping configuration"
        exit 0
        ;;
        
    *)
        print_error "Invalid option!"
        exit 1
        ;;
esac

# Test configuration
echo ""
print_info "Testing Claude configuration..."
if claude --version &>/dev/null; then
    print_msg "Claude Code is working!"
    echo ""
    print_info "Version: $(claude --version)"
    echo ""
    print_msg "Quick commands:"
    echo "  claude chat          - Interactive chat"
    echo "  claude code         - Code assistance"
    echo "  claude --help       - See all options"
    
    if [ "$AUTH_METHOD" = "1" ]; then
        echo ""
        print_info "Max/Pro Plan commands:"
        echo "  /model              - Switch between models"
        echo "  /logout             - Logout from session"
    fi
else
    print_error "Claude Code test failed!"
    print_info "Try running: claude --help"
fi

echo ""
print_msg "Setup complete!"