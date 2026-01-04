#!/bin/bash

# Smart Shell - An intelligent terminal shell
# Features:
# 1. Execute correct commands with valid arguments
# 2. Suggest and replace mistyped commands
# 3. Leverage Qwen Code CLI to understand input intention and suggest commands

# Note: Removed 'set -e' to prevent script from exiting on utility function errors

# Color constants
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Set SCRIPT_DIR to the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source configuration and utility functions
source "$SCRIPT_DIR/config.sh" 2>/dev/null || true
source "$SCRIPT_DIR/utils.sh" 2>/dev/null || true

# Initialize the smart shell
initialize_shell() {
    echo -e "${CYAN}Smart Shell v1.0 - Enhanced Terminal Experience${NC}"
    echo -e "${YELLOW}Type 'help' for available commands or 'exit' to quit${NC}"
    echo ""
}

# Main shell loop
main_loop() {
    # Enable history expansion and configure history settings
    set -H
    HISTSIZE=1000
    HISTFILESIZE=1000
    HISTCONTROL=ignoredups
    HISTFILE="$HOME/.smart_shell_history"

    # Load history from file if it exists
    if [ -f "$HISTFILE" ]; then
        history -r
    fi

    while true; do
        # Display prompt with colors
        printf "\n${GREEN}%s${NC}@${CYAN}smart_shell${NC}:${BLUE}%s${NC}$ " "$USER" "$PWD"

        # Read user input with Readline support (enables arrow keys, history, etc.)
        read -e -r input

        # Add command to history if not empty and save to file
        if [ -n "$input" ]; then
            history -s "$input"  # Add to history
            history -w  # Write history to file
        fi

        # Process the input
        process_input "$input"
    done
}

# Process user input
process_input() {
    local input="$1"

    # Handle special commands
    case "$input" in
        "exit"|"quit")
            echo -e "${RED}Goodbye!${NC}"
            exit 0
            ;;
        "help")
            show_help
            return 0
            ;;
        "history")
            history
            return 0
            ;;
        "")
            return 0
            ;;
    esac

    # First check if it's a valid command before using Qwen
    if is_valid_command "$input"; then
        execute_command "$input"
    else
        # If not a valid command, leverage Qwen to correct or interpret the input
        suggested_command=$(interpret_intention_with_qwen "$input")
        if [ -n "$suggested_command" ]; then
            # Show the converted command and execute it
            echo -e "${YELLOW}Executing Qwen suggestion: ${GREEN}$suggested_command${NC}"
            execute_command "$suggested_command"
        else
            # If Qwen doesn't provide a suggestion, show error
            echo -e "${RED}Command not found: $input${NC}"
            echo -e "${YELLOW}You can try describing what you want to do in plain English, and I'll try to suggest a command.${NC}"
        fi
    fi
}

# Execute a command safely
execute_command() {
    local cmd="$1"

    # Execute the command and show output
    eval "$cmd" 2>&1
    local exit_code=$?
    return $exit_code
}

# Show help information
show_help() {
    echo -e "${CYAN}Smart Shell Help:${NC}"
    echo -e "  - ${GREEN}Enter any valid command to execute it${NC}"
    echo -e "  - ${GREEN}Describe what you want to do in natural language and Smart Shell will suggest commands using Qwen AI${NC}"
    echo -e "  - ${GREEN}Type 'exit' or 'quit' to exit the shell${NC}"
    echo -e "  - ${GREEN}Type 'help' to show this help message${NC}"
    echo -e "  - ${GREEN}Type 'history' to show command history${NC}"
}

# Check if a command is valid
is_valid_command() {
    local cmd="$1"
    local command_part=$(echo "$cmd" | cut -d' ' -f1)

    # Handle special shell operators
    case "$command_part" in
        "cd"|"pushd"|"popd"|"export"|"alias"|"unalias"|"source"|"."|"history"|"fc")
            # These commands need to be executed in the current shell
            # For now, we'll just validate they exist
            return 0
            ;;
    esac

    # Check if it's a built-in command
    if builtin type -t "$command_part" > /dev/null 2>&1; then
        return 0
    fi

    # Check if it's an executable in PATH
    if command -v "$command_part" > /dev/null 2>&1; then
        return 0
    fi

    return 1
}


# Initialize and start the shell
initialize_shell
main_loop