#!/bin/bash
# Safe malware analysis script with security checks

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Security checks
echo -e "${YELLOW}[*] Running security checks...${NC}"

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
   echo -e "${RED}[!] ERROR: Do not run malware analysis as root!${NC}"
   exit 1
fi

# Check network isolation
if ping -c 1 8.8.8.8 &> /dev/null; then
    echo -e "${RED}[!] WARNING: Network is NOT isolated! Aborting.${NC}"
    exit 1
else
    echo -e "${GREEN}[+] Network isolation confirmed${NC}"
fi

# Check filesystem
if touch /test_write 2>/dev/null; then
    echo -e "${YELLOW}[!] WARNING: Root filesystem is writable${NC}"
    rm -f /test_write
fi

# Display container limits
echo -e "${GREEN}[*] Container limits:${NC}"
echo "Memory limit: $(cat /sys/fs/cgroup/memory/memory.limit_in_bytes 2>/dev/null || echo 'Unknown')"
echo "CPU quota: $(cat /sys/fs/cgroup/cpu/cpu.cfs_quota_us 2>/dev/null || echo 'Unknown')"
echo "PID limit: $(cat /sys/fs/cgroup/pids/pids.max 2>/dev/null || echo 'Unknown')"

# Analysis function
analyze_file() {
    local file="$1"
    local report_dir="/reports/$(date +%Y%m%d_%H%M%S)_$(basename "$file")"
    
    echo -e "${GREEN}[*] Analyzing: $file${NC}"
    echo -e "${GREEN}[*] Report directory: $report_dir${NC}"
    
    mkdir -p "$report_dir"
    
    # Basic info
    {
        echo "=== File Information ==="
        file "$file"
        echo
        echo "=== Hashes ==="
        echo "MD5: $(md5sum "$file" | cut -d' ' -f1)"
        echo "SHA256: $(sha256sum "$file" | cut -d' ' -f1)"
        echo
        echo "=== Size ==="
        ls -lh "$file"
    } > "$report_dir/basic_info.txt"
    
    # Strings (limited output)
    echo -e "${YELLOW}[*] Extracting strings...${NC}"
    strings -n 8 "$file" | head -1000 > "$report_dir/strings.txt"
    
    # Hex dump (first 1KB)
    xxd -l 1024 "$file" > "$report_dir/hexdump.txt"
    
    # YARA scan if available
    if command -v yara &> /dev/null; then
        echo -e "${YELLOW}[*] Running YARA scan...${NC}"
        # Use built-in rules if available
        if [ -d "/opt/yara-rules" ]; then
            yara -r /opt/yara-rules/ "$file" > "$report_dir/yara_results.txt" 2>&1 || true
        fi
    fi
    
    # PE analysis if applicable
    if file "$file" | grep -q "PE32"; then
        echo -e "${YELLOW}[*] Analyzing PE file...${NC}"
        python3 -c "
import pefile
import sys
try:
    pe = pefile.PE(sys.argv[1])
    print('Entry Point:', hex(pe.OPTIONAL_HEADER.AddressOfEntryPoint))
    print('Image Base:', hex(pe.OPTIONAL_HEADER.ImageBase))
    print('Sections:')
    for section in pe.sections:
        print(f'  {section.Name.decode().rstrip(chr(0))}: {hex(section.VirtualAddress)}')
except Exception as e:
    print(f'Error: {e}')
" "$file" > "$report_dir/pe_analysis.txt" 2>&1 || true
    fi
    
    echo -e "${GREEN}[+] Analysis complete! Results in: $report_dir${NC}"
}

# Main
if [ $# -eq 0 ]; then
    echo "Safe Malware Analysis Script"
    echo "Usage: $0 <malware_sample>"
    echo ""
    echo "This script performs safe static analysis in an isolated environment."
    exit 0
fi

# Confirm before analysis
echo -e "${YELLOW}[!] WARNING: You are about to analyze potentially malicious files.${NC}"
echo -e "${YELLOW}[!] Ensure you are running this in an isolated container!${NC}"
read -p "Continue? (yes/no): " response

if [[ "$response" != "yes" ]]; then
    echo "Aborted."
    exit 0
fi

# Analyze file
analyze_file "$1"