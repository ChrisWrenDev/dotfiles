#!/bin/bash

# Master installation script for all dotfiles
# Supports: macOS, Ubuntu/Debian, Arch Linux, WSL

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ -f /etc/arch-release ]]; then
        echo "arch"
    elif [[ -f /etc/debian_version ]]; then
        if grep -qi microsoft /proc/version 2>/dev/null; then
            echo "wsl"
        else
            echo "ubuntu"
        fi
    elif grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl"
    else
        echo "unknown"
    fi
}

print_header() {
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================${NC}"
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

# List of all available tools
TOOLS=(
    "nvim:Neovim - Modern Vim-based text editor"
    "tmux:tmux - Terminal multiplexer"
    "wezterm:WezTerm - GPU-accelerated terminal emulator"
    "zsh:Zsh - Z shell with Starship prompt"
    "vscode:VS Code - Visual Studio Code editor"
    "keyboard:QMK - Keyboard firmware"
    "opencode:OpenCode - AI coding assistant"
)

# Install all tools
install_all() {
    local os=$(detect_os)
    print_header "Installing all tools for $os"

    for tool_info in "${TOOLS[@]}"; do
        local tool="${tool_info%%:*}"
        local desc="${tool_info#*:}"
        
        echo ""
        print_header "Installing $desc"
        
        if [[ -x "$SCRIPT_DIR/$tool.sh" ]]; then
            "$SCRIPT_DIR/$tool.sh" install || print_warning "Failed to install $tool"
        else
            print_error "Script not found: $SCRIPT_DIR/$tool.sh"
        fi
    done

    print_success "All tools installed!"
}

# Deploy all dotfiles
deploy_all() {
    print_header "Deploying all dotfiles"

    for tool_info in "${TOOLS[@]}"; do
        local tool="${tool_info%%:*}"
        local desc="${tool_info#*:}"
        
        echo ""
        echo "Deploying $desc..."
        
        if [[ -x "$SCRIPT_DIR/$tool.sh" ]]; then
            "$SCRIPT_DIR/$tool.sh" deploy || print_warning "Failed to deploy $tool"
        else
            print_error "Script not found: $SCRIPT_DIR/$tool.sh"
        fi
    done

    print_success "All dotfiles deployed!"
}

# Sync all dotfiles back
sync_all() {
    print_header "Syncing all dotfiles back to repo"

    for tool_info in "${TOOLS[@]}"; do
        local tool="${tool_info%%:*}"
        local desc="${tool_info#*:}"
        
        echo ""
        echo "Syncing $desc..."
        
        if [[ -x "$SCRIPT_DIR/$tool.sh" ]]; then
            "$SCRIPT_DIR/$tool.sh" sync || print_warning "Failed to sync $tool"
        else
            print_error "Script not found: $SCRIPT_DIR/$tool.sh"
        fi
    done

    print_success "All dotfiles synced!"
}

# Interactive tool selection
select_tools() {
    local action="$1"
    
    echo "Available tools:"
    echo ""
    
    local i=1
    for tool_info in "${TOOLS[@]}"; do
        local tool="${tool_info%%:*}"
        local desc="${tool_info#*:}"
        echo "  $i) $desc"
        ((i++))
    done
    
    echo ""
    echo "  a) All tools"
    echo "  q) Quit"
    echo ""
    
    read -p "Select tools (comma-separated numbers, 'a' for all, or 'q' to quit): " selection
    
    if [[ "$selection" == "q" ]]; then
        exit 0
    elif [[ "$selection" == "a" ]]; then
        case $action in
            install) install_all ;;
            deploy) deploy_all ;;
            sync) sync_all ;;
        esac
    else
        IFS=',' read -ra SELECTIONS <<< "$selection"
        for sel in "${SELECTIONS[@]}"; do
            sel=$(echo "$sel" | tr -d ' ')
            if [[ "$sel" =~ ^[0-9]+$ ]] && [[ "$sel" -ge 1 ]] && [[ "$sel" -le ${#TOOLS[@]} ]]; then
                local tool_info="${TOOLS[$((sel-1))]}"
                local tool="${tool_info%%:*}"
                
                echo ""
                print_header "Running $action for $tool"
                "$SCRIPT_DIR/$tool.sh" "$action" || print_warning "Failed to $action $tool"
            else
                print_warning "Invalid selection: $sel"
            fi
        done
    fi
}

# Show usage
usage() {
    local os=$(detect_os)
    
    echo "Dotfiles Installation Script"
    echo "Detected OS: $os"
    echo ""
    echo "Usage: $0 {install|deploy|sync|interactive} [tool]"
    echo ""
    echo "Commands:"
    echo "  install [tool]     - Install tools (all if no tool specified)"
    echo "  deploy [tool]      - Deploy/symlink dotfiles (all if no tool specified)"
    echo "  sync [tool]        - Sync dotfiles back to repo (all if no tool specified)"
    echo "  interactive        - Interactive mode to select tools"
    echo ""
    echo "Available tools:"
    for tool_info in "${TOOLS[@]}"; do
        local tool="${tool_info%%:*}"
        local desc="${tool_info#*:}"
        printf "  %-12s - %s\n" "$tool" "$desc"
    done
    echo ""
    echo "Examples:"
    echo "  $0 install           # Install all tools"
    echo "  $0 install nvim      # Install only Neovim"
    echo "  $0 deploy            # Deploy all dotfiles"
    echo "  $0 sync zsh          # Sync only zsh config back to repo"
    echo "  $0 interactive       # Interactive mode"
    exit 1
}

# Main
case "${1:-}" in
    install)
        if [[ -n "${2:-}" ]]; then
            if [[ -x "$SCRIPT_DIR/$2.sh" ]]; then
                "$SCRIPT_DIR/$2.sh" install
            else
                print_error "Unknown tool: $2"
                exit 1
            fi
        else
            install_all
        fi
        ;;
    deploy)
        if [[ -n "${2:-}" ]]; then
            if [[ -x "$SCRIPT_DIR/$2.sh" ]]; then
                "$SCRIPT_DIR/$2.sh" deploy
            else
                print_error "Unknown tool: $2"
                exit 1
            fi
        else
            deploy_all
        fi
        ;;
    sync)
        if [[ -n "${2:-}" ]]; then
            if [[ -x "$SCRIPT_DIR/$2.sh" ]]; then
                "$SCRIPT_DIR/$2.sh" sync
            else
                print_error "Unknown tool: $2"
                exit 1
            fi
        else
            sync_all
        fi
        ;;
    interactive)
        echo "What would you like to do?"
        echo "  1) Install tools"
        echo "  2) Deploy dotfiles"
        echo "  3) Sync dotfiles back to repo"
        echo ""
        read -p "Select action (1-3): " action_choice
        
        case $action_choice in
            1) select_tools install ;;
            2) select_tools deploy ;;
            3) select_tools sync ;;
            *) print_error "Invalid selection" && exit 1 ;;
        esac
        ;;
    *)
        usage
        ;;
esac
