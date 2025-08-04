#!/bin/bash

echo "Starting Kali Linux Docker Environment..."

if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker Desktop for Mac."
    exit 1
fi

cd "$(dirname "$0")/.."

echo "[*] Pulling latest Kali Linux base image..."
docker pull kalilinux/kali-rolling:latest

echo "[*] Building Docker image..."
docker-compose build

echo "[*] Starting containers..."
# Check if container already exists
if docker ps -a | grep -q kali-workspace; then
    echo "[*] Container kali-workspace already exists"
    if docker ps | grep -q kali-workspace; then
        echo "[*] Container is already running"
    else
        echo "[*] Starting existing container..."
        docker start kali-workspace
    fi
else
    echo "[*] Creating new container..."
    docker-compose up -d
fi

echo "[*] Ensuring XQuartz is installed..."
if ! command -v xquartz &> /dev/null && ! [ -d "/Applications/Utilities/XQuartz.app" ]; then
    echo "⚠️  XQuartz not found. Installing..."
    brew install --cask xquartz
    echo "❗ Please restart your computer after XQuartz installation and run this script again."
    exit 1
fi

echo "[*] Starting XQuartz..."
open -a XQuartz 2>/dev/null || true
sleep 2

echo "[*] Configuring X11 access..."
xhost +localhost 2>/dev/null || true

echo "[*] Kali Linux is now running!"
echo ""
echo "Access methods:"
echo "1. CLI: docker exec -it kali-workspace /bin/zsh"
echo "2. GUI Apps: ./scripts/kali-gui-app.sh <app-name>"
echo "3. Full Desktop: ./scripts/kali-desktop.sh"
echo ""
echo "Example GUI apps:"
echo "  ./scripts/kali-gui-app.sh firefox-esr"
echo "  ./scripts/kali-gui-app.sh xfce4-terminal"
echo "  ./scripts/kali-gui-app.sh wireshark"
echo ""
echo "To stop: ./scripts/stop-kali.sh"
echo ""
echo "💡 Tip: GUI apps will open as native macOS windows!"