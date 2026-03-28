#!/usr/bin/env bash

# Claude Code Development Kit Setup Script
#
# This script installs the Claude Code Development Kit into a target project,
# providing automated context management and multi-agent workflows for Claude Code.

set -euo pipefail

# Script directory (where this script lives)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration variables
TARGET_DIR=""
INSTALL_CONTEXT7="n"
INSTALL_GEMINI="n"
INSTALL_BEADS="n"
INSTALL_NOTIFICATIONS="n"
OS=""
AUDIO_PLAYER=""
OVERWRITE_ALL="n"
SKIP_ALL="n"
BEADS_AVAILABLE="n"
BEADS_PACKAGE_MANAGER=""

# Print colored output
print_color() {
    local color=$1
    shift
    echo -e "${color}$@${NC}"
}

# Print header
print_header() {
    echo
    print_color "$BLUE" "==========================================="
    print_color "$BLUE" "   Claude Code Development Kit Setup"
    print_color "$BLUE" "==========================================="
    echo
}

# Safe read function that works in piped contexts
# Usage: safe_read <variable_name> <prompt_string>
safe_read() {
    local var_name="$1"
    local prompt="$2"
    local temp_input  # Renamed to avoid scope collision

    # Check if a TTY is available for interactive input
    if [ ! -t 0 ] && [ ! -c /dev/tty ]; then
        print_color "$RED" "❌ Cannot prompt for input: No TTY available."
        return 1
    fi

    # Determine the input source
    local input_source
    if [ -t 0 ]; then
        input_source="/dev/stdin" # Standard input is the terminal
    else
        input_source="/dev/tty"   # Standard input is piped, use the terminal
    fi

    # Use read -p for the prompt. The prompt is sent to stderr by default
    # when reading from a source other than the terminal, so it's visible.
    read -r -p "$prompt" temp_input < "$input_source"

    # Assign the value to the variable name passed as the first argument
    # using `printf -v`. This is a safer way to do indirect assignment.
    printf -v "$var_name" '%s' "$temp_input"
}

# Safe read function for yes/no questions with validation
# Usage: safe_read_yn <variable_name> <prompt_string>
safe_read_yn() {
    local var_name="$1"
    local prompt="$2"
    local user_input
    local sanitized_input
    local valid_input=false

    while [ "$valid_input" = false ]; do
        if ! safe_read user_input "$prompt"; then
            return 1
        fi

        # Sanitize input: remove carriage returns and whitespace
        sanitized_input="${user_input//$'\r'/}"  # Remove \r
        sanitized_input="$(echo "$sanitized_input" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')"

        case "$sanitized_input" in
            y|n)
                valid_input=true
                printf -v "$var_name" '%s' "$sanitized_input"
                ;;
            *)
                print_color "$YELLOW" "Please enter 'y' for yes or 'n' for no."
                ;;
        esac
    done
}

# Safe read function for file conflict choices with validation
# Usage: safe_read_conflict <variable_name>
safe_read_conflict() {
    local var_name="$1"
    local user_input
    local sanitized_input
    local valid_input=false

    while [ "$valid_input" = false ]; do
        if ! safe_read user_input "   Your choice: "; then
            return 1
        fi

        # Sanitize input: remove carriage returns and whitespace
        sanitized_input="${user_input//$'\r'/}"  # Remove \r
        sanitized_input="$(echo "$sanitized_input" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')"

        case "$sanitized_input" in
            o|s|a|n)
                valid_input=true
                printf -v "$var_name" '%s' "$sanitized_input"
                ;;
            *)
                print_color "$YELLOW" "   Invalid choice. Please enter o, s, a, or n."
                ;;
        esac
    done
}

# Check if Claude Code is installed
check_claude_code() {
    print_color "$YELLOW" "Checking prerequisites..."

    if ! command -v claude &> /dev/null; then
        print_color "$RED" "❌ Claude Code is not installed or not in PATH"
        echo "Please install Claude Code from: https://github.com/anthropics/claude-code"
        echo "After installation, make sure 'claude' command is available in your terminal"
        exit 1
    fi

    print_color "$GREEN" "✓ Claude Code is installed"
}

# Check for required tools
check_required_tools() {
    local missing_tools=()

    for tool in jq grep cat mkdir cp chmod; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done

    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_color "$RED" "❌ Missing required tools: ${missing_tools[*]}"
        echo
        echo "These tools are needed for:"
        echo "  • jq     - Parse and generate JSON configuration files"
        echo "  • grep   - Search and filter file contents"
        echo "  • cat    - Read and display files"
        echo "  • mkdir  - Create directory structure"
        echo "  • cp     - Copy framework files"
        echo "  • chmod  - Set executable permissions on scripts"
        echo
        echo "On macOS: Most are pre-installed, install jq with: brew install jq"
        echo "On Ubuntu/Debian: sudo apt-get install ${missing_tools[*]}"
        echo "On other systems: Use your package manager to install these tools"
        exit 1
    fi

    print_color "$GREEN" "✓ All required tools are available"
}

# Check if beads can be installed (requires brew/npm/pnpm/yarn)
check_beads_prerequisites() {
    # Check for available package managers
    if command -v brew &> /dev/null; then
        BEADS_AVAILABLE="y"
        BEADS_PACKAGE_MANAGER="brew"
    elif command -v npm &> /dev/null; then
        BEADS_AVAILABLE="y"
        BEADS_PACKAGE_MANAGER="npm"
    elif command -v pnpm &> /dev/null; then
        BEADS_AVAILABLE="y"
        BEADS_PACKAGE_MANAGER="pnpm"
    elif command -v yarn &> /dev/null; then
        BEADS_AVAILABLE="y"
        BEADS_PACKAGE_MANAGER="yarn"
    fi
}

# Detect operating system
detect_os() {
    case "$(uname -s)" in
        Darwin*)
            OS="macOS"
            AUDIO_PLAYER="afplay"
            ;;
        Linux*)
            OS="Linux"
            # Check for available audio players
            for player in paplay aplay pw-play play ffplay; do
                if command -v "$player" &> /dev/null; then
                    AUDIO_PLAYER="$player"
                    break
                fi
            done
            ;;
        MINGW*|MSYS*|CYGWIN*)
            OS="Windows"
            AUDIO_PLAYER="powershell"
            ;;
        *)
            OS="Unknown"
            AUDIO_PLAYER=""
            ;;
    esac

    print_color "$GREEN" "✓ Detected OS: $OS"
}

# Get target directory
get_target_directory() {
    echo
    print_color "$YELLOW" "Where would you like to install the Claude Code Development Kit?"
    local prompt="Enter target project directory (or . for current directory): "
    if ! safe_read input_dir "$prompt"; then
        exit 1
    fi

    if [ "$input_dir" = "." ]; then
        # If run from installer, use the original directory
        if [ -n "${INSTALLER_ORIGINAL_PWD:-}" ]; then
            TARGET_DIR="$INSTALLER_ORIGINAL_PWD"
        else
            # Otherwise use current directory (for manual runs)
            TARGET_DIR="$(pwd)"
        fi
    else
        # For relative paths, resolve from the original PWD (if run via installer)
        if [[ "$input_dir" != /* ]] && [ -n "${INSTALLER_ORIGINAL_PWD:-}" ]; then
            TARGET_DIR="$INSTALLER_ORIGINAL_PWD/$input_dir"
        else
            # For absolute paths or when running directly
            if [[ "$input_dir" = /* ]]; then
                TARGET_DIR="$input_dir"
            else
                TARGET_DIR="$(pwd)/$input_dir"
            fi
        fi
        # Normalize the path (remove . and .., trailing slashes)
        TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)" || {
            # Directory doesn't exist yet - construct absolute path manually
            TARGET_DIR="$(cd "$(dirname "$TARGET_DIR")" 2>/dev/null && pwd)/$(basename "$TARGET_DIR")"
        }
    fi

    # Check if target is the framework source directory
    if [ "$TARGET_DIR" = "$SCRIPT_DIR" ]; then
        print_color "$RED" "❌ Cannot install framework into its own source directory"
        echo "Please choose a different target directory"
        exit 1
    fi

    print_color "$GREEN" "✓ Target directory: $TARGET_DIR"
}

# Prompt for optional components
prompt_optional_components() {
    echo
    print_color "$YELLOW" "Optional Components:"
    echo

    # Context7 MCP
    print_color "$CYAN" "Context7 MCP Server (Highly Recommended)"
    echo "  Provides up-to-date documentation for external libraries (React, FastAPI, etc.)"
    if ! safe_read_yn INSTALL_CONTEXT7 "  Install Context7 integration? (y/n): "; then
        exit 1
    fi
    echo

    # Gemini MCP
    print_color "$CYAN" "Gemini Assistant MCP Server (Highly Recommended)"
    echo "  Enables architectural consultation and advanced code review capabilities"
    if ! safe_read_yn INSTALL_GEMINI "  Install Gemini integration? (y/n): "; then
        exit 1
    fi
    echo

    # Beads Task Tracker
    if [ "$BEADS_AVAILABLE" = "y" ]; then
        print_color "$CYAN" "Beads Task Tracker (Recommended for Multi-Session Work)"
        echo "  Persistent task tracking with dependency graph for long-running projects"
        echo "  Will be installed via: $BEADS_PACKAGE_MANAGER"
        if ! safe_read_yn INSTALL_BEADS "  Install Beads integration? (y/n): "; then
            exit 1
        fi
    else
        print_color "$YELLOW" "Beads Task Tracker — Not Available"
        echo "  Requires one of: brew, npm, pnpm, or yarn"
        echo "  Install a package manager to enable this option"
        INSTALL_BEADS="n"
    fi
    echo

    # Notifications
    print_color "$CYAN" "Notification System (Convenience Feature)"
    echo "  Plays audio alerts when tasks complete or input is needed"
    if ! safe_read_yn INSTALL_NOTIFICATIONS "  Set up notification hooks? (y/n): "; then
        exit 1
    fi

    # Only detect OS if notifications are enabled
    if [ "$INSTALL_NOTIFICATIONS" = "y" ]; then
        detect_os
        if [ -z "$AUDIO_PLAYER" ] && [ "$OS" = "Linux" ]; then
            print_color "$YELLOW" "⚠️  No audio player found. Install one of: paplay, aplay, pw-play, play, ffplay"
        fi
    fi
}

# Create directory structure
create_directories() {
    print_color "$YELLOW" "Creating directory structure..."

    # Main directories
    mkdir -p "$TARGET_DIR/.claude/commands"
    mkdir -p "$TARGET_DIR/.claude/hooks/config"
    mkdir -p "$TARGET_DIR/workflow/ai-context"
    mkdir -p "$TARGET_DIR/workflow/addons"
    mkdir -p "$TARGET_DIR/workflow/open-issues"
    mkdir -p "$TARGET_DIR/workflow/specs"
    mkdir -p "$TARGET_DIR/logs"

    # Only create sounds directory if notifications are enabled
    if [ "$INSTALL_NOTIFICATIONS" = "y" ]; then
        mkdir -p "$TARGET_DIR/.claude/hooks/sounds"
    fi

    print_color "$GREEN" "✓ Directory structure created"
}

# Helper function to handle file conflicts
handle_file_conflict() {
    local source_file="$1"
    local dest_file="$2"
    local file_type="$3"

    # If policies are already set, apply them
    if [ "$OVERWRITE_ALL" = "y" ]; then
        cp "$source_file" "$dest_file"
        return 0
    elif [ "$SKIP_ALL" = "y" ]; then
        return 1
    fi

    # Show conflict and ask user
    print_color "$YELLOW" "⚠️  File already exists: $(basename "$dest_file")"
    echo "   Type: $file_type"
    echo "   Location: $dest_file"
    echo
    echo "   What would you like to do?"
    echo "   [o] Overwrite - Replace the existing file with the new one"
    echo "   [s] Skip - Keep the existing file, don't copy the new one"
    echo "   [a] Always overwrite - Replace this and all future existing files"
    echo "   [n] Never overwrite - Skip this and all future existing files"
    echo
    if ! safe_read_conflict choice; then
        return 1
    fi

    case "$choice" in
        o)
            cp "$source_file" "$dest_file"
            print_color "$GREEN" "   ✓ Overwritten"
            return 0
            ;;
        s)
            print_color "$YELLOW" "   → Skipped"
            return 1
            ;;
        a)
            OVERWRITE_ALL="y"
            cp "$source_file" "$dest_file"
            print_color "$GREEN" "   ✓ Overwritten (will automatically overwrite all future conflicts)"
            return 0
            ;;
        n)
            SKIP_ALL="y"
            print_color "$YELLOW" "   → Skipped (will automatically skip all future conflicts)"
            return 1
            ;;
        *)
            print_color "$RED" "   Invalid choice, skipping file"
            return 1
            ;;
    esac
}

# Copy a file with conflict handling
copy_with_check() {
    local source="$1"
    local dest="$2"
    local file_type="$3"

    if [ -f "$dest" ]; then
        handle_file_conflict "$source" "$dest" "$file_type"
    else
        cp "$source" "$dest"
    fi
}

# Copy framework files
copy_framework_files() {
    print_color "$YELLOW" "Copying framework files..."
    echo

    # Copy commands
    if [ -d "$SCRIPT_DIR/commands" ]; then
        for cmd in "$SCRIPT_DIR/commands/"*.md; do
            if [ -f "$cmd" ]; then
                basename_cmd="$(basename "$cmd")"
                # Skip gemini-consult.md unless Gemini is selected
                if [ "$basename_cmd" = "gemini-consult.md" ] && [ "$INSTALL_GEMINI" != "y" ]; then
                    continue
                fi
                dest="$TARGET_DIR/.claude/commands/$basename_cmd"
                copy_with_check "$cmd" "$dest" "Command template"
            fi
        done

        # Copy beads commands if Beads is selected
        if [ "$INSTALL_BEADS" = "y" ] && [ -d "$SCRIPT_DIR/commands/bd" ]; then
            mkdir -p "$TARGET_DIR/.claude/commands/bd"
            for bd_cmd in "$SCRIPT_DIR/commands/bd/"*.md; do
                if [ -f "$bd_cmd" ]; then
                    dest="$TARGET_DIR/.claude/commands/bd/$(basename "$bd_cmd")"
                    copy_with_check "$bd_cmd" "$dest" "Beads command"
                fi
            done
        fi
    fi

    # Copy hooks based on user selections
    if [ -d "$SCRIPT_DIR/hooks" ]; then
        # Always copy subagent context injector (core feature)
        if [ -f "$SCRIPT_DIR/hooks/subagent-context-injector.sh" ]; then
            copy_with_check "$SCRIPT_DIR/hooks/subagent-context-injector.sh" \
                          "$TARGET_DIR/.claude/hooks/subagent-context-injector.sh" \
                          "Hook script (core feature)"
        fi

        # Copy MCP security scanner if any MCP server is selected
        if [ "$INSTALL_CONTEXT7" = "y" ] || [ "$INSTALL_GEMINI" = "y" ]; then
            if [ -f "$SCRIPT_DIR/hooks/mcp-security-scan.sh" ]; then
                copy_with_check "$SCRIPT_DIR/hooks/mcp-security-scan.sh" \
                              "$TARGET_DIR/.claude/hooks/mcp-security-scan.sh" \
                              "MCP security scanner hook"
            fi
        fi

        # Copy Gemini context injector if Gemini is selected
        if [ "$INSTALL_GEMINI" = "y" ]; then
            if [ -f "$SCRIPT_DIR/hooks/gemini-context-injector.sh" ]; then
                copy_with_check "$SCRIPT_DIR/hooks/gemini-context-injector.sh" \
                              "$TARGET_DIR/.claude/hooks/gemini-context-injector.sh" \
                              "Gemini context injector hook"
            fi
        fi

        # Copy notification hook and sounds if notifications are selected
        if [ "$INSTALL_NOTIFICATIONS" = "y" ]; then
            if [ -f "$SCRIPT_DIR/hooks/notify.sh" ]; then
                copy_with_check "$SCRIPT_DIR/hooks/notify.sh" \
                              "$TARGET_DIR/.claude/hooks/notify.sh" \
                              "Notification hook"
            fi

            # Copy sounds with conflict handling
            if [ -d "$SCRIPT_DIR/hooks/sounds" ]; then
                for sound in "$SCRIPT_DIR/hooks/sounds/"*; do
                    if [ -f "$sound" ]; then
                        dest="$TARGET_DIR/.claude/hooks/sounds/$(basename "$sound")"
                        copy_with_check "$sound" "$dest" "Notification sound"
                    fi
                done
            fi
        fi

        # Copy config files with conflict handling
        if [ -d "$SCRIPT_DIR/hooks/config" ]; then
            for config in "$SCRIPT_DIR/hooks/config/"*; do
                if [ -f "$config" ]; then
                    dest="$TARGET_DIR/.claude/hooks/config/$(basename "$config")"
                    copy_with_check "$config" "$dest" "Configuration file"
                fi
            done
        fi

        # Copy README for reference
        if [ -f "$SCRIPT_DIR/hooks/README.md" ]; then
            copy_with_check "$SCRIPT_DIR/hooks/README.md" \
                          "$TARGET_DIR/.claude/hooks/README.md" \
                          "Hooks documentation"
        fi

        # Copy setup files
        if [ -d "$SCRIPT_DIR/hooks/setup" ]; then
            mkdir -p "$TARGET_DIR/.claude/hooks/setup"
            for setup_file in "$SCRIPT_DIR/hooks/setup/"*; do
                if [ -f "$setup_file" ]; then
                    dest="$TARGET_DIR/.claude/hooks/setup/$(basename "$setup_file")"
                    copy_with_check "$setup_file" "$dest" "Setup file"
                fi
            done
        fi
    fi

    # Copy documentation structure
    if [ -d "$SCRIPT_DIR/workflow" ]; then
        # Copy ai-context files
        if [ -d "$SCRIPT_DIR/workflow/ai-context" ]; then
            for doc in "$SCRIPT_DIR/workflow/ai-context/"*.md; do
                if [ -f "$doc" ]; then
                    dest="$TARGET_DIR/workflow/ai-context/$(basename "$doc")"
                    copy_with_check "$doc" "$dest" "AI context documentation"
                fi
            done
        fi

        # Copy example issues
        if [ -d "$SCRIPT_DIR/workflow/open-issues" ]; then
            for issue in "$SCRIPT_DIR/workflow/open-issues/"*.md; do
                if [ -f "$issue" ]; then
                    dest="$TARGET_DIR/workflow/open-issues/$(basename "$issue")"
                    copy_with_check "$issue" "$dest" "Issue template"
                fi
            done
        fi

        # Copy spec templates
        if [ -d "$SCRIPT_DIR/workflow/specs" ]; then
            for spec in "$SCRIPT_DIR/workflow/specs/"*.md; do
                if [ -f "$spec" ]; then
                    dest="$TARGET_DIR/workflow/specs/$(basename "$spec")"
                    copy_with_check "$spec" "$dest" "Specification template"
                fi
            done
        fi

        # Copy docs README
        if [ -f "$SCRIPT_DIR/workflow/README.md" ]; then
            copy_with_check "$SCRIPT_DIR/workflow/README.md" \
                          "$TARGET_DIR/workflow/README.md" \
                          "Documentation guide"
        fi

        # Copy CONTEXT template files
        if [ -f "$SCRIPT_DIR/workflow/CONTEXT-tier2-component.md" ]; then
            copy_with_check "$SCRIPT_DIR/workflow/CONTEXT-tier2-component.md" \
                          "$TARGET_DIR/workflow/CONTEXT-tier2-component.md" \
                          "Tier 2 documentation template"
        fi

        if [ -f "$SCRIPT_DIR/workflow/CONTEXT-tier3-feature.md" ]; then
            copy_with_check "$SCRIPT_DIR/workflow/CONTEXT-tier3-feature.md" \
                          "$TARGET_DIR/workflow/CONTEXT-tier3-feature.md" \
                          "Tier 3 documentation template"
        fi
    fi

    # Create CLAUDE.md from template if it doesn't exist
    if [ ! -f "$TARGET_DIR/CLAUDE.md" ] && [ -f "$SCRIPT_DIR/workflow/CLAUDE.md" ]; then
        cp "$SCRIPT_DIR/workflow/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
        print_color "$GREEN" "✓ Created CLAUDE.md from template"

        # Append Beads section if Beads is selected
        if [ "$INSTALL_BEADS" = "y" ] && [ -f "$SCRIPT_DIR/workflow/ai-context/beads-section.md" ]; then
            cat "$SCRIPT_DIR/workflow/ai-context/beads-section.md" >> "$TARGET_DIR/CLAUDE.md"
            print_color "$GREEN" "✓ Added Beads task management section to CLAUDE.md"
        fi
    else
        if [ -f "$TARGET_DIR/CLAUDE.md" ]; then
            print_color "$YELLOW" "→ Preserved existing CLAUDE.md"
        fi
    fi

    # Create MCP-ASSISTANT-RULES.md from template if Gemini is selected
    if [ "$INSTALL_GEMINI" = "y" ]; then
        if [ ! -f "$TARGET_DIR/workflow/addons/MCP-ASSISTANT-RULES.md" ] && [ -f "$SCRIPT_DIR/workflow/addons/MCP-ASSISTANT-RULES.md" ]; then
            cp "$SCRIPT_DIR/workflow/addons/MCP-ASSISTANT-RULES.md" "$TARGET_DIR/workflow/addons/MCP-ASSISTANT-RULES.md"
            print_color "$GREEN" "✓ Created MCP-ASSISTANT-RULES.md from template"
        else
            if [ -f "$TARGET_DIR/workflow/addons/MCP-ASSISTANT-RULES.md" ]; then
                print_color "$YELLOW" "→ Preserved existing MCP-ASSISTANT-RULES.md"
            fi
        fi
    else
        print_color "$YELLOW" "→ Skipped MCP-ASSISTANT-RULES.md (Gemini not selected)"
    fi

    # Copy beads session check hook if Beads is selected
    if [ "$INSTALL_BEADS" = "y" ] && [ -f "$SCRIPT_DIR/hooks/beads-session-check.sh" ]; then
        copy_with_check "$SCRIPT_DIR/hooks/beads-session-check.sh" \
                      "$TARGET_DIR/.claude/hooks/beads-session-check.sh" \
                      "Beads session check hook"
    fi

    print_color "$GREEN" "✓ Framework files copied"
}

# Set executable permissions
set_permissions() {
    print_color "$YELLOW" "Setting file permissions..."

    # Make only copied shell scripts executable
    if [ -d "$TARGET_DIR/.claude/hooks" ]; then
        for script in "$TARGET_DIR/.claude/hooks/"*.sh; do
            if [ -f "$script" ]; then
                chmod +x "$script"
            fi
        done
    fi

    print_color "$GREEN" "✓ Permissions set"
}

# Generate configuration file
generate_config() {
    print_color "$YELLOW" "Generating configuration..."

    local config_file="$TARGET_DIR/.claude/settings.local.json"

    # Start building the configuration with new hooks format
    cat > "$config_file" << EOF
{
  "hooks": {
EOF

    # PreToolUse hooks
    local pretooluse_hooks=()

    # Security scan hook for MCP tools
    if [ "$INSTALL_CONTEXT7" = "y" ] || [ "$INSTALL_GEMINI" = "y" ]; then
        pretooluse_hooks+=("mcp-security")
    fi

    # Gemini context injector
    if [ "$INSTALL_GEMINI" = "y" ]; then
        pretooluse_hooks+=("gemini-context")
    fi

    # Always add sub-agent context injector
    pretooluse_hooks+=("subagent-context")

    # Write PreToolUse hooks
    if [ ${#pretooluse_hooks[@]} -gt 0 ]; then
        cat >> "$config_file" << EOF
    "PreToolUse": [
EOF

        local first_hook=true

        # MCP security scanner
        if [[ " ${pretooluse_hooks[@]} " =~ " mcp-security " ]]; then
            [ "$first_hook" = false ] && echo "," >> "$config_file"
            cat >> "$config_file" << EOF
      {
        "matcher": "mcp__",
        "hooks": [
          {
            "type": "command",
            "command": "bash $TARGET_DIR/.claude/hooks/mcp-security-scan.sh"
          }
        ]
      }
EOF
            first_hook=false
        fi

        # Gemini context injector
        if [[ " ${pretooluse_hooks[@]} " =~ " gemini-context " ]]; then
            [ "$first_hook" = false ] && echo "," >> "$config_file"
            cat >> "$config_file" << EOF
      {
        "matcher": "mcp__gemini",
        "hooks": [
          {
            "type": "command",
            "command": "bash $TARGET_DIR/.claude/hooks/gemini-context-injector.sh"
          }
        ]
      }
EOF
            first_hook=false
        fi

        # Sub-agent context injector
        [ "$first_hook" = false ] && echo "," >> "$config_file"
        cat >> "$config_file" << EOF
      {
        "matcher": "Task",
        "hooks": [
          {
            "type": "command",
            "command": "bash $TARGET_DIR/.claude/hooks/subagent-context-injector.sh"
          }
        ]
      }
EOF

        cat >> "$config_file" << EOF
    ]
EOF
    fi

    # Add notification hooks if enabled
    if [ "$INSTALL_NOTIFICATIONS" = "y" ]; then
        [ ${#pretooluse_hooks[@]} -gt 0 ] && echo "," >> "$config_file"
        cat >> "$config_file" << EOF
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash $TARGET_DIR/.claude/hooks/notify.sh input"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash $TARGET_DIR/.claude/hooks/notify.sh complete"
          }
        ]
      }
    ]
EOF
    fi

    # Add beads session check hook if Beads is enabled
    if [ "$INSTALL_BEADS" = "y" ]; then
        [ ${#pretooluse_hooks[@]} -gt 0 ] || [ "$INSTALL_NOTIFICATIONS" = "y" ] && echo "," >> "$config_file"
        cat >> "$config_file" << EOF
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash $TARGET_DIR/.claude/hooks/beads-session-check.sh"
          }
        ]
      }
    ]
EOF
    fi

    cat >> "$config_file" << EOF

  }
}
EOF

    print_color "$GREEN" "✓ Configuration generated: $config_file"
}

# Initialize beads in target directory
initialize_beads() {
    print_color "$YELLOW" "Initializing Beads..."

    # Check if beads CLI is already installed
    if command -v bd &> /dev/null; then
        print_color "$GREEN" "✓ Beads CLI already installed"
    else
        print_color "$YELLOW" "Installing Beads CLI via $BEADS_PACKAGE_MANAGER..."

        case "$BEADS_PACKAGE_MANAGER" in
            brew)
                if brew install beads 2>/dev/null; then
                    print_color "$GREEN" "✓ Beads installed via Homebrew"
                else
                    print_color "$YELLOW" "⚠️  Could not install via brew. Install manually: brew install beads"
                fi
                ;;
            npm)
                if npm install -g @beads/bd 2>/dev/null; then
                    print_color "$GREEN" "✓ Beads installed via npm"
                else
                    print_color "$YELLOW" "⚠️  Could not install via npm. Install manually: npm install -g @beads/bd"
                fi
                ;;
            pnpm)
                if pnpm add -g @beads/bd 2>/dev/null; then
                    print_color "$GREEN" "✓ Beads installed via pnpm"
                else
                    print_color "$YELLOW" "⚠️  Could not install via pnpm. Install manually: pnpm add -g @beads/bd"
                fi
                ;;
            yarn)
                if yarn global add @beads/bd 2>/dev/null; then
                    print_color "$GREEN" "✓ Beads installed via yarn"
                else
                    print_color "$YELLOW" "⚠️  Could not install via yarn. Install manually: yarn global add @beads/bd"
                fi
                ;;
        esac
    fi

    # Initialize beads in target directory
    if command -v bd &> /dev/null; then
        if [ ! -d "$TARGET_DIR/.beads" ]; then
            (cd "$TARGET_DIR" && bd init --stealth --quiet)
            print_color "$GREEN" "✓ Beads initialized"

            # Generate BEADS.md documentation
            if (cd "$TARGET_DIR" && bd setup claude -o "$TARGET_DIR/workflow/addons/BEADS.md" 2>/dev/null); then
                print_color "$GREEN" "✓ Beads documentation generated"
            fi
        else
            print_color "$YELLOW" "→ Beads already initialized"
        fi
    else
        print_color "$YELLOW" "⚠️  Beads CLI not available. Install manually"
    fi
}

# Display MCP server information
display_mcp_info() {
    if [ "$INSTALL_CONTEXT7" = "y" ] || [ "$INSTALL_GEMINI" = "y" ]; then
        echo
        print_color "$BLUE" "=== MCP Server Setup (Required) ==="
        echo
        echo "To complete the setup, you need to install the MCP servers you selected:"
        echo

        if [ "$INSTALL_CONTEXT7" = "y" ]; then
            print_color "$YELLOW" "Context7 MCP Server:"
            echo "  Repository: https://github.com/upstash/context7"
            echo "  Documentation: See the Context7 README for setup instructions"
            echo
        fi

        if [ "$INSTALL_GEMINI" = "y" ]; then
            print_color "$YELLOW" "Gemini MCP Server:"
            echo "  Repository: https://github.com/mishagin-dev/mcp-gemini-assistant"
            echo "  Documentation: See the MCP Gemini Assistant README for setup instructions"
            echo
        fi

        echo "After installing the MCP servers, add their configuration to:"
        print_color "$BLUE" "  $TARGET_DIR/.claude/settings.local.json"
        echo
        echo "Add a 'mcpServers' section with the appropriate server configurations."
    fi

    # Beads task tracker info
    if [ "$INSTALL_BEADS" = "y" ]; then
        echo
        print_color "$BLUE" "=== Beads Task Tracker ==="
        echo
        print_color "$GREEN" "✓ Beads CLI installed and initialized"
        print_color "$YELLOW" "Quick start:"
        echo "  /bd:work   - Find and claim a ready task"
        echo "  /bd:create - Create a new task"
        echo "  /bd:close  - Close completed task"
        echo
        echo "  Full docs: $TARGET_DIR/workflow/addons/BEADS.md"
        echo "  GitHub: https://github.com/steveyegge/beads"
        echo
    fi
}

# Show next steps
show_next_steps() {
    echo
    print_color "$GREEN" "=== Installation Complete! ==="
    echo
    print_color "$YELLOW" "Next Steps:"
    echo
    local step_num=1

    echo "${step_num}. Customize your project context:"
    echo "   - Edit: $TARGET_DIR/CLAUDE.md"
    echo "   - Update project structure in: $TARGET_DIR/workflow/ai-context/project-structure.md"
    echo
    ((step_num++))

    if [ "$INSTALL_GEMINI" = "y" ]; then
        echo "${step_num}. Set your coding standards for Gemini:"
        echo "   - Edit: $TARGET_DIR/workflow/addons/MCP-ASSISTANT-RULES.md"
        echo
        ((step_num++))
    fi

    if [ "$INSTALL_CONTEXT7" = "y" ] || [ "$INSTALL_GEMINI" = "y" ]; then
        echo "${step_num}. Configure security patterns:"
        echo "   - Edit: $TARGET_DIR/.claude/hooks/config/sensitive-patterns.json"
        echo
        ((step_num++))
    fi

    if [ "$INSTALL_BEADS" = "y" ]; then
        echo "${step_num}. Start using Beads task tracking:"
        echo "   /bd:work   - Find and claim a ready task"
        echo "   /bd:create - Create a new task"
        echo "   Docs: workflow/addons/BEADS.md"
        echo
        ((step_num++))
    fi

    echo "${step_num}. Test your installation:"
    echo "   - Run: claude"
    echo "   - Then: /full-context \"analyze my project structure\""
    echo
    ((step_num++))

    if [ "$INSTALL_NOTIFICATIONS" = "y" ]; then
        echo "${step_num}. Test notifications:"
        echo "   - Run: bash $TARGET_DIR/.claude/hooks/notify.sh"
        echo
        ((step_num++))
    fi

    echo "${step_num}. Documentation Templates:"
    print_color "$CYAN" "   The framework includes documentation templates:"
    echo "   - $TARGET_DIR/workflow/CONTEXT-tier2-component.md"
    echo "   - $TARGET_DIR/workflow/CONTEXT-tier3-feature.md"
    echo
    echo "   These are TEMPLATES. To use them:"
    echo "   • Copy to your component/feature directories and rename to CONTEXT.md"
    echo "   • OR use the /create-docs command to generate documentation automatically"
    echo

    print_color "$BLUE" "For documentation and examples, see:"
    echo "  - Commands: $TARGET_DIR/.claude/commands/README.md"
    echo "  - Hooks: $TARGET_DIR/.claude/hooks/README.md"
    echo "  - Docs: $TARGET_DIR/workflow/README.md"
}

# Main execution
main() {
    print_header

    # Run checks
    check_claude_code
    check_required_tools
    check_beads_prerequisites

    # Get user input
    get_target_directory
    prompt_optional_components

    # Confirm installation
    echo
    print_color "$YELLOW" "Ready to install Claude Code Development Kit to:"
    echo "  $TARGET_DIR"
    echo
    if ! safe_read_yn confirm "Continue? (y/n): "; then
        exit 1
    fi

    if [ "$confirm" != "y" ]; then
        print_color "$RED" "Installation cancelled"
        exit 0
    fi

    # Perform installation
    create_directories
    copy_framework_files
    set_permissions
    generate_config

    # Initialize beads if selected
    if [ "$INSTALL_BEADS" = "y" ]; then
        initialize_beads
    fi

    # Show completion information
    display_mcp_info
    show_next_steps
}

# Run the script
main "$@"
