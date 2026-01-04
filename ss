#!/bin/bash

# Smart Shell Quick Entrypoint
# This script provides a quick way to enter Smart Shell mode by typing 'ss'
# It runs the main smart_shell.sh script from the user's installed location

# Find the Smart Shell installation directory
SMART_SHELL_DIR="$HOME/.smart_shell"

# Check if Smart Shell is installed
if [ ! -f "$SMART_SHELL_DIR/smart_shell.sh" ]; then
    echo "Error: Smart Shell is not installed or not found in $SMART_SHELL_DIR"
    echo "Please install Smart Shell first using the installation script."
    exit 1
fi

# Run the main Smart Shell script
exec "$SMART_SHELL_DIR/smart_shell.sh"