#!/bin/bash

# WezTerm installation and dotfiles management script
# Supports: macOS, Ubuntu/Debian, Arch Linux, WSL

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WEZTERM_CONFIG="$HOME/.wezterm.lua"

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

# Install WezTerm
install_wezterm() {
    local os=$(detect_os)
    echo "Detected OS: $os"
    echo "Installing WezTerm..."

    case $os in
        macos)
            if ! command -v brew &> /dev/null; then
                echo "Homebrew not found. Please install Homebrew first."
                exit 1
            fi
            brew install --cask wezterm
            ;;
        ubuntu|wsl)
            # Add WezTerm repository
            curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
            echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
            sudo apt-get update
            sudo apt-get install -y wezterm
            ;;
        arch)
            sudo pacman -S --noconfirm wezterm
            ;;
        *)
            echo "Unsupported OS. Please install WezTerm manually."
            echo "Visit: https://wezfurlong.org/wezterm/installation.html"
            exit 1
            ;;
    esac

    echo "WezTerm installed successfully!"
}

# Deploy dotfiles (symlink config)
deploy() {
    echo "Deploying WezTerm configuration..."
    
    # Backup existing config if it exists and is not a symlink
    if [[ -e "$WEZTERM_CONFIG" && ! -L "$WEZTERM_CONFIG" ]]; then
        echo "Backing up existing config to ${WEZTERM_CONFIG}.backup"
        mv "$WEZTERM_CONFIG" "${WEZTERM_CONFIG}.backup"
    fi

    # Remove existing symlink if present
    if [[ -L "$WEZTERM_CONFIG" ]]; then
        rm "$WEZTERM_CONFIG"
    fi

    # Create symlink
    ln -s "$DOTFILES_DIR/wezterm/.wezterm.lua" "$WEZTERM_CONFIG"
    echo "WezTerm configuration deployed!"
}

# Sync dotfiles back to this repo
sync() {
    echo "Syncing WezTerm configuration back to dotfiles..."
    
    if [[ -L "$WEZTERM_CONFIG" ]]; then
        echo "Config is already a symlink, no sync needed."
        return
    fi

    if [[ -f "$WEZTERM_CONFIG" ]]; then
        cp "$WEZTERM_CONFIG" "$DOTFILES_DIR/wezterm/.wezterm.lua"
        echo "WezTerm configuration synced!"
    else
        echo "No WezTerm configuration found at $WEZTERM_CONFIG"
        exit 1
    fi
}

# Show usage
usage() {
    echo "Usage: $0 {install|deploy|sync}"
    echo ""
    echo "Commands:"
    echo "  install  - Install WezTerm for your OS"
    echo "  deploy   - Symlink dotfiles to ~/.wezterm.lua"
    echo "  sync     - Copy config from ~/.wezterm.lua back to dotfiles"
    exit 1
}

# Main
case "${1:-}" in
    install)
        install_wezterm
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
