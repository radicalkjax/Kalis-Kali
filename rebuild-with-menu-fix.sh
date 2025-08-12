#!/bin/bash
# Rebuild Docker image with Kali menu fixes

echo "Rebuilding Kali Docker image with menu fixes..."
echo "============================================="

# Stop existing containers
echo "Stopping existing containers..."
docker-compose down

# Remove old image
echo "Removing old image..."
docker rmi kali-custom:latest 2>/dev/null || true

# Rebuild with no cache to ensure all packages are installed
echo "Building new image with menu fixes..."
docker-compose build --no-cache kali

echo ""
echo "Build complete!"
echo ""
echo "The Docker image now includes:"
echo "✓ kali-menu package"
echo "✓ kali-desktop-xfce for integration"
echo "✓ xfce4-whiskermenu-plugin"
echo "✓ All menu support packages"
echo "✓ Automatic menu verification on startup"
echo ""
echo "To start the container with the fixes:"
echo "  docker-compose up -d kali"
echo ""
echo "Then run your desktop scripts as usual!"