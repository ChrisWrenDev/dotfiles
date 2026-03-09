#!/bin/bash

# OpenCode installation and dotfiles management script
# Supports: macOS, Ubuntu/Debian, Arch Linux, WSL

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OPENCODE_CONFIG_DIR="$HOME/.config/opencode"

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

# Install OpenCode and dependencies
install_opencode() {
    local os=$(detect_os)
    echo "Detected OS: $os"
    echo "Installing OpenCode dependencies..."

    # Check for bun
    if ! command -v bun &> /dev/null; then
        echo "Installing Bun..."
        curl -fsSL https://bun.sh/install | bash
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
    fi

    # Install OpenCode CLI
    echo "Installing OpenCode CLI..."
    case $os in
        macos)
            if command -v brew &> /dev/null; then
                brew install opencode-ai/tap/opencode || {
                    echo "Falling back to npm install..."
                    npm install -g opencode
                }
            else
                npm install -g opencode
            fi
            ;;
        *)
            npm install -g opencode || bun install -g opencode
            ;;
    esac

    echo "OpenCode installed successfully!"
}

# Deploy dotfiles (symlink config)
deploy() {
    echo "Deploying OpenCode configuration..."
    
    # Backup existing config if it exists and is not a symlink
    if [[ -e "$OPENCODE_CONFIG_DIR" && ! -L "$OPENCODE_CONFIG_DIR" ]]; then
        echo "Backing up existing config to ${OPENCODE_CONFIG_DIR}.backup"
        mv "$OPENCODE_CONFIG_DIR" "${OPENCODE_CONFIG_DIR}.backup"
    fi

    # Remove existing symlink if present
    if [[ -L "$OPENCODE_CONFIG_DIR" ]]; then
        rm "$OPENCODE_CONFIG_DIR"
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$OPENCODE_CONFIG_DIR")"

    # Create symlink
    ln -s "$DOTFILES_DIR/opencode" "$OPENCODE_CONFIG_DIR"
    
    # Install dependencies
    echo "Installing OpenCode plugin dependencies..."
    cd "$OPENCODE_CONFIG_DIR"
    if command -v bun &> /dev/null; then
        bun install
    else
        npm install
    fi

    echo "OpenCode configuration deployed!"
}

# Sync dotfiles back to this repo
sync() {
    echo "Syncing OpenCode configuration back to dotfiles..."
    
    if [[ -L "$OPENCODE_CONFIG_DIR" ]]; then
        echo "Config is already a symlink, no sync needed."
        return
    fi

    if [[ -d "$OPENCODE_CONFIG_DIR" ]]; then
        # Sync agents directory
        if [[ -d "$OPENCODE_CONFIG_DIR/agents" ]]; then
            rm -rf "$DOTFILES_DIR/opencode/agents"
            cp -r "$OPENCODE_CONFIG_DIR/agents" "$DOTFILES_DIR/opencode/agents"
        fi

        # Sync commands directory
        if [[ -d "$OPENCODE_CONFIG_DIR/commands" ]]; then
            rm -rf "$DOTFILES_DIR/opencode/commands"
            cp -r "$OPENCODE_CONFIG_DIR/commands" "$DOTFILES_DIR/opencode/commands"
        fi

        # Sync package.json
        if [[ -f "$OPENCODE_CONFIG_DIR/package.json" ]]; then
            cp "$OPENCODE_CONFIG_DIR/package.json" "$DOTFILES_DIR/opencode/package.json"
        fi

        echo "OpenCode configuration synced!"
    else
        echo "No OpenCode configuration found at $OPENCODE_CONFIG_DIR"
        exit 1
    fi
}

# Show usage
usage() {
    echo "Usage: $0 {install|deploy|sync}"
    echo ""
    echo "Commands:"
    echo "  install  - Install OpenCode CLI and Bun"
    echo "  deploy   - Symlink dotfiles to ~/.config/opencode"
    echo "  sync     - Copy config from ~/.config/opencode back to dotfiles"
    exit 1
}

# Main
case "${1:-}" in
    install)
        install_opencode
        ;;
    deploy)
        deploy
        ;;
    sync)
        sync
        ;;
    *)
        usage
        ;;
esac
