#!/bin/bash
# Test script to debug Kali package installation

echo "=== Testing Kali Package Installation ==="
echo ""

# Test 1: Check if we can execute commands in the container
echo "Test 1: Checking container execution..."
docker exec -u root kali-workspace bash -c "echo 'Container execution works!'"

# Test 2: Check if heredoc works
echo ""
echo "Test 2: Testing heredoc execution..."
docker exec -u root kali-workspace bash << 'EOF'
echo "Inside heredoc - this should print"
echo "Current user: $(whoami)"
echo "Current directory: $(pwd)"
EOF

# Test 3: Check apt sources
echo ""
echo "Test 3: Checking apt sources..."
docker exec -u root kali-workspace bash -c "cat /etc/apt/sources.list"

# Test 4: Check if kali-tools packages are available
echo ""
echo "Test 4: Searching for kali-tools packages..."
docker exec -u root kali-workspace bash -c "apt-cache search ^kali-tools- | wc -l"

# Test 5: Try to install one small package
echo ""
echo "Test 5: Testing package installation..."
docker exec -u root kali-workspace bash << 'EOF'
echo "Updating apt cache..."
apt-get update -qq
echo "Searching for kali-tools-information-gathering..."
apt-cache show kali-tools-information-gathering | head -10
echo "Attempting to install kali-menu (should already be installed)..."
apt-get install -y kali-menu
echo "Exit code: $?"
EOF

echo ""
echo "=== Test Complete ==="