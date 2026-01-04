#!/bin/bash

# Utility functions for Smart Shell

# Simple function to indicate API call is in progress
show_api_progress() {
    echo -e "\033[1;33mContacting Qwen API...\033[0m" >&2
}

# Generate a list of common commands (this will be used for typo correction)
generate_commands_list() {
    local script_dir
    if [ -n "$SCRIPT_DIR" ]; then
        script_dir="$SCRIPT_DIR"
    else
        script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    fi

    local commands_file="$script_dir/commands.txt"
    
    # If commands file doesn't exist, create it with common commands
    if [ ! -f "$commands_file" ]; then
        {
            echo "ls"
            echo "cd"
            echo "pwd"
            echo "cat"
            echo "grep"
            echo "find"
            echo "cp"
            echo "mv"
            echo "rm"
            echo "mkdir"
            echo "rmdir"
            echo "touch"
            echo "ps"
            echo "top"
            echo "htop"
            echo "kill"
            echo "df"
            echo "du"
            echo "free"
            echo "ping"
            echo "curl"
            echo "wget"
            echo "git"
            echo "vim"
            echo "nano"
            echo "nano"
            echo "less"
            echo "more"
            echo "head"
            echo "tail"
            echo "sort"
            echo "uniq"
            echo "wc"
            echo "chmod"
            echo "chown"
            echo "ssh"
            echo "scp"
            echo "tar"
            echo "zip"
            echo "unzip"
            echo "man"
            echo "which"
            echo "whereis"
            echo "history"
            echo "echo"
            echo "export"
            echo "alias"
            echo "unalias"
            echo "source"
            echo "exit"
            echo "logout"
            echo "clear"
            echo "reset"
            echo "date"
            echo "time"
            echo "sleep"
            echo "seq"
            echo "yes"
            echo "nohup"
        } > "$commands_file"
        
        # Add commands from PATH (with error handling)
        {
            IFS=':' read -ra PATHS <<< "$PATH"
            for path_dir in "${PATHS[@]}"; do
                if [ -n "$path_dir" ] && [ -d "$path_dir" ]; then
                    find "$path_dir" -maxdepth 1 -type f -executable -exec basename {} \; 2>/dev/null | sort -u
                fi
            done
        } >> "$commands_file" 2>/dev/null

        # Remove duplicates (macOS compatibility)
        if [ -f "$commands_file" ]; then
            sort -u "$commands_file" | uniq > "${commands_file}.tmp" && mv "${commands_file}.tmp" "$commands_file" 2>/dev/null
        fi
    fi
}

# Calculate similarity between two strings using a more sophisticated approach
string_similarity() {
    local str1="$1"
    local str2="$2"

    # Convert to lowercase for comparison
    str1=$(echo "$str1" | tr '[:upper:]' '[:lower:]')
    str2=$(echo "$str2" | tr '[:upper:]' '[:lower:]')

    # If strings are identical, return 1.0
    if [ "$str1" = "$str2" ]; then
        echo "1.0"
        return
    fi

    # Use a more sophisticated similarity algorithm (Longest Common Subsequence based)
    local len1=${#str1}
    local len2=${#str2}

    # Calculate the length of the longest common subsequence
    local lcs_len=$(lcs_length "$str1" "$str2")

    # Calculate similarity as the ratio of LCS to the average length
    local avg_len=$(( (len1 + len2) / 2 ))
    if [ $avg_len -eq 0 ]; then
        echo "1.0"
        return
    fi

    local similarity=$(echo "$lcs_len $avg_len" | awk '{printf "%.2f", $1/$2}')
    echo "$similarity"
}

# Helper function to calculate longest common subsequence length
lcs_length() {
    local s1="$1"
    local s2="$2"
    local len1=${#s1}
    local len2=${#s2}

    # For bash compatibility, use a simpler approach without associative arrays
    # Use a basic similarity algorithm based on matching characters
    local match_count=0
    local min_len=$((len1 < len2 ? len1 : len2))

    # Count matching characters at the same positions
    for ((i=0; i<min_len; i++)); do
        if [ "${s1:$i:1}" = "${s2:$i:1}" ]; then
            ((match_count++))
        fi
    done

    # Also consider matching characters regardless of position
    local s1_sorted=$(echo "$s1" | grep -o . | sort | tr -d '\n')
    local s2_sorted=$(echo "$s2" | grep -o . | sort | tr -d '\n')
    local common_chars=0

    # Count common characters
    local temp_s2="$s2_sorted"
    for ((i=0; i<${#s1_sorted}; i++)); do
        local char="${s1_sorted:$i:1}"
        if [[ "$temp_s2" == *"$char"* ]]; then
            ((common_chars++))
            temp_s2="${temp_s2/$char/}"  # Remove first occurrence
        fi
    done

    # Return the maximum of position-based and character-based matches
    local result=$((match_count > common_chars ? match_count : common_chars))
    echo "$result"
}

# Suggest correction for a mistyped command
suggest_correction() {
    local input="$1"
    local command_part=$(echo "$input" | cut -d' ' -f1)

    if [ "$ENABLE_TYPO_CORRECTION" != "true" ]; then
        echo ""
        return 0
    fi

    # Simple hardcoded corrections for common typos
    case "$command_part" in
        "lss")
            echo "ls"
            return 0
            ;;
        "lsl")
            echo "ls"
            return 0
            ;;
        "cls")
            echo "clear"
            return 0
            ;;
        "gir")
            echo "git"
            return 0
            ;;
        "got")
            echo "git"
            return 0
            ;;
        "mz")
            echo "mv"
            return 0
            ;;
        "rmm")
            echo "rm"
            return 0
            ;;
        "pc")
            echo "cp"
            return 0
            ;;
        "mrd")
            echo "mkdir"
            return 0
            ;;
    esac

    # If no simple correction found, try the full algorithm
    # Determine the commands file path
    local script_dir
    if [ -n "$SCRIPT_DIR" ]; then
        script_dir="$SCRIPT_DIR"
    else
        # Fallback: try to determine script directory
        if [ -n "${BASH_SOURCE[0]}" ]; then
            script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        else
            script_dir="."
        fi
    fi

    local commands_file="$script_dir/commands.txt"

    # Ensure the commands file exists - use the pre-existing one if available
    if [ ! -f "$commands_file" ]; then
        # If the file doesn't exist, create a minimal one
        {
            echo "ls"
            echo "cd"
            echo "pwd"
            echo "cat"
            echo "grep"
            echo "find"
            echo "cp"
            echo "mv"
            echo "rm"
            echo "mkdir"
        } > "$commands_file" 2>/dev/null || true
    fi

    # Check if commands file exists and is readable
    if [ ! -f "$commands_file" ] || [ ! -r "$commands_file" ]; then
        echo ""
        return 0
    fi

    local best_match=""
    local best_score=0

    # Read commands file safely
    while IFS= read -r cmd || [ -n "$cmd" ]; do  # The || [ -n "$cmd" ] handles last line without newline
        if [ -n "$cmd" ]; then
            local score=$(string_similarity "$command_part" "$cmd")
            local score_float=$(printf "%.2f" "$score")
            local threshold_float=$(printf "%.2f" "$FUZZY_THRESHOLD")

            if (( $(echo "$score_float $threshold_float" | awk '{print ($1 > $2)}') )) && (( $(echo "$score $best_score" | awk '{print ($1 > $2)}') )); then
                best_match="$cmd"
                best_score="$score"
            fi
        fi
    done < "$commands_file"

    if [ -n "$best_match" ] && [ "$best_match" != "$command_part" ]; then
        # Replace the first word in the input with the corrected command
        local corrected="${input/$command_part/$best_match}"
        echo "$corrected"
    else
        echo ""
    fi

    return 0
}

# Interpret user intention using Qwen Code
interpret_intention_with_qwen() {
    local input="$1"

    if [ "$ENABLE_QWEN_INTEGRATION" != "true" ]; then
        echo ""
        return
    fi

    # Check if qwen command is available
    if ! command -v qwen &> /dev/null; then
        echo "Warning: qwen command not found. Please install Qwen Code to use this feature."
        echo ""
        return
    fi

    # Prepare the prompt for Qwen - more specific instructions
    local prompt="Convert this natural language to a bash command: $input. Respond with only a single-line command and arguments, no explanations, no additional text, no newlines, no markdown formatting."

    # Call Qwen with timeout (cross-platform compatible)
    local result

    # Check if timeout command is available (Linux)
    if command -v timeout &> /dev/null; then
        # Run the API call and capture result directly (suppress progress indicator)
        result=$(timeout "$QWEN_TIMEOUT" qwen "$prompt" 2>/dev/null) || {
            # Suppress error message
            echo ""
            return
        }
    # Check if gtimeout command is available (macOS with GNU coreutils)
    elif command -v gtimeout &> /dev/null; then
        # Run the API call and capture result directly (suppress progress indicator)
        result=$(gtimeout "$QWEN_TIMEOUT" qwen "$prompt" 2>/dev/null) || {
            # Suppress error message
            echo ""
            return
        }
    else
        # Fallback: run without timeout (suppress warning)
        # Run the API call and capture result directly (suppress progress indicator)
        result=$(qwen "$prompt" 2>/dev/null) || {
            # Suppress error message
            echo ""
            return
        }
    fi

    # Clean up the result - remove any extra text that might have been included
    # First, strip markdown code block formatting
    result=$(echo "$result" | sed -E 's/^```[a-z]*\n?//g' | sed 's/```$//g')

    # Then, strip backticks that might surround the command
    result=$(echo "$result" | sed 's/^`\(.*\)`$/\1/')

    # Take only the first line to ensure single-line command
    result=$(echo "$result" | head -n 1)

    # Remove leading and trailing whitespace (including newlines)
    result=$(echo "$result" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

    # If Qwen returned a response with explanation, try to extract just the command
    if [[ "$result" =~ ^(\/bin\/bash[[:space:]]*-[c]?[[:space:]]*|bash[[:space:]]*-[c]?[[:space:]]*)(.*)$ ]]; then
        # Found bash prefix at the start (e.g., "bash -c pwd")
        result="${BASH_REMATCH[2]}"
    elif [[ "$result" =~ ^(.*)[[:space:]]+(\/bin\/bash[[:space:]]*-[c]?[[:space:]]*|bash[[:space:]]*-[c]?[[:space:]]*)(.*)$ ]]; then
        # Found bash prefix after some text (e.g., "explanation bash -c pwd")
        result="${BASH_REMATCH[3]}"
    else
        # No bash prefix, return the whole string
        result="$result"
    fi

    # Remove quotes if they surround the entire command
    result=$(echo "$result" | sed 's/^"\(.*\)"$/\1/' | sed "s/^'\(.*\)'$/\1/")

    # If result is not empty, return it
    if [ -n "$result" ] && [ "$result" != "$input" ]; then
        # Basic validation to ensure it's not a response like "I can't help with that"
        if [[ ! "$result" =~ ^[Ii].* ]] && [[ ! "$result" =~ .*can\'t.* ]] && [[ ! "$result" =~ .*unable.* ]] && [[ ! "$result" =~ .*sorry.* ]]; then
            echo "$result"
        else
            echo ""
        fi
    else
        echo ""
    fi
}