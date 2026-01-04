#!/bin/bash

# Smart Shell Installation Script
# This script installs Smart Shell and its dependencies

# Color constants
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Print colored output
print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on macOS or Linux
detect_platform() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        PLATFORM="macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        PLATFORM="linux"
    else
        PLATFORM="unknown"
    fi
}

# Check if a command exists
command_exists() {
    command -v "$1" > /dev/null 2>&1
}

# Install dependencies based on platform
install_dependencies() {
    print_info "Detecting platform..."
    detect_platform
    
    if [[ "$PLATFORM" == "macos" ]]; then
        print_info "Detected macOS"
        
        # Check if Homebrew is installed
        if ! command_exists "brew"; then
            print_info "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        
        # Install GNU coreutils for timeout command
        if ! command_exists "gtimeout"; then
            print_info "Installing GNU coreutils..."
            brew install coreutils
        fi
        
        # Install Python if not available
        if ! command_exists "python3"; then
            print_info "Installing Python..."
            brew install python3
        fi
        
    elif [[ "$PLATFORM" == "linux" ]]; then
        print_info "Detected Linux"
        
        # Install dependencies based on package manager
        if command_exists "apt-get"; then
            print_info "Installing dependencies with apt..."
            sudo apt-get update
            sudo apt-get install -y python3 python3-pip curl wget
        elif command_exists "yum"; then
            print_info "Installing dependencies with yum..."
            sudo yum install -y python3 python3-pip curl wget
        elif command_exists "dnf"; then
            print_info "Installing dependencies with dnf..."
            sudo dnf install -y python3 python3-pip curl wget
        elif command_exists "pacman"; then
            print_info "Installing dependencies with pacman..."
            sudo pacman -Sy python3 python-pip curl wget
        else
            print_warning "Could not detect package manager. Please install python3, pip, curl, and wget manually."
        fi
    else
        print_warning "Unknown platform. Please ensure dependencies are installed manually."
    fi
}

# Install Qwen Code
install_qwen_code() {
    # Check if qwen command already exists
    if command_exists "qwen"; then
        print_info "Qwen Code is already installed. Skipping installation."
        return 0
    fi

    print_info "Installing Qwen Code..."

    # Check if Node.js is available
    if ! command_exists "node"; then
        print_info "Node.js is required but not found. Installing Node.js..."

        # Install Node.js based on platform
        if [[ "$PLATFORM" == "macos" ]]; then
            if command_exists "brew"; then
                brew install node
            else
                print_error "Homebrew is required to install Node.js on macOS."
                print_info "Please install Homebrew first: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
                return 1
            fi
        elif [[ "$PLATFORM" == "linux" ]]; then
            if command_exists "apt-get"; then
                sudo apt-get update
                sudo apt-get install -y nodejs npm
            elif command_exists "yum"; then
                sudo yum install -y nodejs npm
            elif command_exists "dnf"; then
                sudo dnf install -y nodejs npm
            elif command_exists "pacman"; then
                sudo pacman -Sy nodejs npm
            else
                print_error "Could not detect package manager. Please install Node.js manually."
                print_info "Visit https://nodejs.org/ for installation instructions."
                return 1
            fi
        fi
    else
        # Check Node.js version
        NODE_VERSION=$(node -v | cut -d'v' -f2)
        MIN_VERSION="20.0.0"

        if [[ $(printf '%s\n' "$MIN_VERSION" "$NODE_VERSION" | sort -V | head -n1) != "$MIN_VERSION" ]]; then
            print_warning "Node.js version $NODE_VERSION is below the minimum required version $MIN_VERSION"
            print_info "Consider updating Node.js for optimal Qwen Code performance"
        fi
    fi

    # Check if npm is available
    if ! command_exists "npm"; then
        print_error "npm is not available. Please install npm first."
        return 1
    fi

    # Install Qwen Code globally
    if ! npm install -g @qwen-code/qwen-code@latest; then
        print_error "Failed to install Qwen Code"
        return 1
    fi

    print_success "Qwen Code installed successfully"
}

# Install Smart Shell
install_smart_shell() {
    print_info "Installing Smart Shell..."
    
    # Default installation directory
    INSTALL_DIR="$HOME/.smart_shell"
    
    # Create installation directory
    mkdir -p "$INSTALL_DIR"
    
    # Download Smart Shell files from GitHub
    if command_exists "curl"; then
        print_info "Downloading Smart Shell files using curl..."
        curl -fsSL "https://raw.githubusercontent.com/barbarum/smart_shell/main/smart_shell.sh" -o "$INSTALL_DIR/smart_shell.sh"
        curl -fsSL "https://raw.githubusercontent.com/barbarum/smart_shell/main/config.sh" -o "$INSTALL_DIR/config.sh"
        curl -fsSL "https://raw.githubusercontent.com/barbarum/smart_shell/main/utils.sh" -o "$INSTALL_DIR/utils.sh"
        curl -fsSL "https://raw.githubusercontent.com/barbarum/smart_shell/main/commands.txt" -o "$INSTALL_DIR/commands.txt"
        curl -fsSL "https://raw.githubusercontent.com/barbarum/smart_shell/main/README.md" -o "$INSTALL_DIR/README.md"
        curl -fsSL "https://raw.githubusercontent.com/barbarum/smart_shell/main/LICENSE" -o "$INSTALL_DIR/LICENSE"
    elif command_exists "wget"; then
        print_info "Downloading Smart Shell files using wget..."
        wget -q "https://raw.githubusercontent.com/barbarum/smart_shell/main/smart_shell.sh" -O "$INSTALL_DIR/smart_shell.sh"
        wget -q "https://raw.githubusercontent.com/barbarum/smart_shell/main/config.sh" -O "$INSTALL_DIR/config.sh"
        wget -q "https://raw.githubusercontent.com/barbarum/smart_shell/main/utils.sh" -O "$INSTALL_DIR/utils.sh"
        wget -q "https://raw.githubusercontent.com/barbarum/smart_shell/main/commands.txt" -O "$INSTALL_DIR/commands.txt"
        wget -q "https://raw.githubusercontent.com/barbarum/smart_shell/main/README.md" -O "$INSTALL_DIR/README.md"
        wget -q "https://raw.githubusercontent.com/barbarum/smart_shell/main/LICENSE" -O "$INSTALL_DIR/LICENSE"
    else
        print_error "Neither curl nor wget is available. Cannot download Smart Shell files."
        return 1
    fi
    
    # Make the main script executable
    chmod +x "$INSTALL_DIR/smart_shell.sh"
    
    print_success "Smart Shell installed to $INSTALL_DIR"
}

# Create an alias for easy access
setup_alias() {
    print_info "Setting up alias..."
    
    # Determine shell configuration file
    if [[ -n "$ZSH_VERSION" ]]; then
        CONFIG_FILE="$HOME/.zshrc"
    elif [[ -n "$BASH_VERSION" ]]; then
        CONFIG_FILE="$HOME/.bashrc"
    else
        CONFIG_FILE="$HOME/.bashrc"  # Default to bash
    fi
    
    # Add alias to shell configuration
    if ! grep -q "alias smart_shell=" "$CONFIG_FILE" 2>/dev/null; then
        echo "" >> "$CONFIG_FILE"
        echo "# Smart Shell alias" >> "$CONFIG_FILE"
        echo "alias smart_shell='$HOME/.smart_shell/smart_shell.sh'" >> "$CONFIG_FILE"
        print_success "Alias added to $CONFIG_FILE"
        print_info "Run 'source $CONFIG_FILE' or restart your terminal to use the alias"
    else
        print_info "Alias already exists in $CONFIG_FILE"
    fi
}

# Main installation function
main() {
    print_info "Starting Smart Shell installation..."

    # Install dependencies
    install_dependencies

    # Install Qwen Code
    if ! install_qwen_code; then
        print_error "Failed to install Qwen Code. Installation cannot continue."
        exit 1
    fi

    # Install Smart Shell
    if ! install_smart_shell; then
        print_error "Failed to install Smart Shell."
        exit 1
    fi

    # Setup alias
    setup_alias

    print_success "Smart Shell installation completed!"
    print_info "To start Smart Shell, run: $HOME/.smart_shell/smart_shell.sh"
    print_info "Or use the alias: smart_shell (after sourcing your shell config)"
    print_info "For more information, visit: https://github.com/barbarum/smart_shell"
}

# Run main function
main "$@"