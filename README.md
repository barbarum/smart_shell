# Smart Shell

An intelligent terminal shell that leverages AI to understand natural language input and execute appropriate commands. Smart Shell enhances your terminal experience by providing intelligent command suggestions and corrections.

## Features

- **Natural Language Processing**: Describe what you want to do in plain English, and Smart Shell will suggest appropriate commands using Qwen AI
- **Command Execution**: Execute valid commands directly with full output visibility
- **Command History**: Full command history with arrow key navigation and persistent storage
- **Colorized Output**: Enhanced visual experience with color-coded prompts and messages
- **Single-line Command Processing**: Ensures clean, single-line command output from AI suggestions
- **Persistent History**: Command history is saved between sessions

## Prerequisites

Before using Smart Shell, ensure you have the following installed:

### Required Dependencies
- **Bash** (version 4.0 or higher)
- **Qwen CLI** - Required for AI command interpretation
- **coreutils** - For basic command-line utilities
- **timeout command** (Linux) or **gtimeout** (macOS with GNU coreutils)

### Installing Qwen CLI

Smart Shell requires the Qwen CLI for AI-powered command interpretation:

```bash
# Install Qwen CLI using pip
pip install qwen-cli

# Or install using your preferred method as per Qwen documentation
```

### Platform-Specific Requirements

**For macOS:**
```bash
# Install GNU coreutils for timeout functionality
brew install coreutils
# This provides gtimeout command
```

**For Linux:**
- The `timeout` command is typically available by default in most distributions

## Installation

1. Clone or download the Smart Shell repository
2. Ensure all prerequisites are installed
3. Make the main script executable:

```bash
chmod +x smart_shell.sh
```

## Usage

Start Smart Shell by running:

```bash
./smart_shell.sh
```

### Available Commands

- `help` - Show help information
- `history` - Show command history
- `exit` or `quit` - Exit the shell

### Examples

Smart Shell can interpret natural language:

```
smart_shell$ find all image files in my home directory
Executing Qwen suggestion: find ~ -type f -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.bmp" -o -name "*.tiff" -o -name "*.webp"
```

Or execute regular commands directly:

```
smart_shell$ ls -la
# Output of ls -la command
```

## Configuration

Configuration options can be found in `config.sh`:

- `QWEN_TIMEOUT` - Timeout for Qwen API calls (in seconds)
- `ENABLE_QWEN_INTEGRATION` - Enable/disable Qwen integration (default: true)
- `MAX_SUGGESTIONS` - Maximum number of suggestions (default: 3)
- `FUZZY_THRESHOLD` - Fuzzy match threshold (0-1, default: 0.6)

## How It Works

1. **Valid Command Detection**: Smart Shell first checks if the input is a valid command
2. **Direct Execution**: Valid commands are executed directly with full output
3. **AI Interpretation**: Invalid commands are sent to Qwen AI for interpretation
4. **Command Execution**: AI-suggested commands are executed with output displayed
5. **History Management**: All commands are saved to persistent history

## History

Smart Shell maintains a command history that persists between sessions:
- Use up/down arrow keys to navigate through command history
- Type `history` to view all previously executed commands
- History is saved to `~/.smart_shell_history`

## Color Scheme

- **Prompt**: Green username, cyan shell name, blue directory
- **Success messages**: Green
- **Warnings/progress**: Yellow
- **Errors**: Red
- **Headers**: Cyan

## Troubleshooting

### Common Issues

1. **Qwen API not responding**: Ensure Qwen CLI is properly installed and configured
2. **Timeout errors**: Check your `QWEN_TIMEOUT` setting in config.sh
3. **Command history not saving**: Ensure you have write permissions to your home directory

### Debugging

If you encounter issues, verify:
- Qwen CLI is installed and accessible from your PATH
- All required dependencies are installed
- Configuration settings in config.sh are correct

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Feel free to submit issues and enhancement requests through the repository.