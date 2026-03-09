#!/bin/bash

# Tmux installation and dotfiles management script
# Supports: macOS, Ubuntu/Debian, Arch Linux, WSL

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMUX_CONF="$HOME/.tmux.conf"

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

# Install tmux
install_tmux() {
    local os=$(detect_os)
    echo "Detected OS: $os"
    echo "Installing tmux..."

    case $os in
        macos)
            if ! command -v brew &> /dev/null; then
                echo "Homebrew not found. Please install Homebrew first."
                exit 1
            fi
            brew install tmux
            ;;
        ubuntu|wsl)
            sudo apt-get update
            sudo apt-get install -y tmux
            ;;
        arch)
            sudo pacman -S --noconfirm tmux
            ;;
        *)
            echo "Unsupported OS. Please install tmux manually."
            exit 1
            ;;
    esac

    # Install TPM (Tmux Plugin Manager)
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        echo "Installing Tmux Plugin Manager (TPM)..."
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    fi

    echo "tmux installed successfully!"
}

# Deploy dotfiles (symlink config)
deploy() {
    echo "Deploying tmux configuration..."
    
    # Backup existing config if it exists and is not a symlink
    if [[ -e "$TMUX_CONF" && ! -L "$TMUX_CONF" ]]; then
        echo "Backing up existing config to ${TMUX_CONF}.backup"
        mv "$TMUX_CONF" "${TMUX_CONF}.backup"
    fi

    # Remove existing symlink if present
    if [[ -L "$TMUX_CONF" ]]; then
        rm "$TMUX_CONF"
    fi

    # Create symlink
    ln -s "$DOTFILES_DIR/tmux/.tmux.conf" "$TMUX_CONF"
    echo "tmux configuration deployed!"
    
    echo ""
    echo "Note: After starting tmux, press prefix + I to install plugins."
}

# Sync dotfiles back to this repo
sync() {
    echo "Syncing tmux configuration back to dotfiles..."
    
    if [[ -L "$TMUX_CONF" ]]; then
        echo "Config is already a symlink, no sync needed."
        return
    fi

    if [[ -f "$TMUX_CONF" ]]; then
        cp "$TMUX_CONF" "$DOTFILES_DIR/tmux/.tmux.conf"
        echo "tmux configuration synced!"
    else
        echo "No tmux configuration found at $TMUX_CONF"
        exit 1
    fi
}

# Show usage
usage() {
    echo "Usage: $0 {install|deploy|sync}"
    echo ""
    echo "Commands:"
    echo "  install  - Install tmux and TPM for your OS"
    echo "  deploy   - Symlink dotfiles to ~/.tmux.conf"
    echo "  sync     - Copy config from ~/.tmux.conf back to dotfiles"
    exit 1
}

# Main
case "${1:-}" in
    install)
        install_tmux
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
