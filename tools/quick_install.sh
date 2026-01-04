#!/bin/bash

# Quick Install Script for Smart Shell
# This script can be used with curl for one-line installation

# Color constants
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Smart Shell Quick Installer${NC}"
echo -e "${YELLOW}This script will install Smart Shell and its dependencies.${NC}"
echo -e "${YELLOW}Note: This includes Node.js and Qwen Code (if not already installed).${NC}"

# Check if curl is available
if ! command -v curl &> /dev/null; then
    echo -e "${RED}curl is required but not installed. Please install curl first.${NC}"
    exit 1
fi

# Download and run the main installation script
echo -e "${BLUE}Downloading main installation script...${NC}"
curl -fsSL https://raw.githubusercontent.com/barbarum/smart_shell/master/tools/install.sh -o /tmp/smart_shell_install.sh

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Main installation script downloaded successfully.${NC}"
    echo -e "${BLUE}Running installation...${NC}"
    chmod +x /tmp/smart_shell_install.sh
    bash /tmp/smart_shell_install.sh
else
    echo -e "${RED}Failed to download the installation script.${NC}"
    exit 1
fi

# Clean up
rm /tmp/smart_shell_install.sh