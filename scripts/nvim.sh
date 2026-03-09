#!/bin/bash

# Neovim installation and dotfiles management script
# Supports: macOS, Ubuntu/Debian, Arch Linux, WSL

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NVIM_CONFIG_DIR="$HOME/.config/nvim"

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

# Install Neovim
install_nvim() {
    local os=$(detect_os)
    echo "Detected OS: $os"
    echo "Installing Neovim..."

    case $os in
        macos)
            if ! command -v brew &> /dev/null; then
                echo "Homebrew not found. Please install Homebrew first."
                exit 1
            fi
            brew install neovim
            ;;
        ubuntu|wsl)
            sudo apt-get update
            sudo apt-get install -y software-properties-common
            sudo add-apt-repository -y ppa:neovim-ppa/unstable
            sudo apt-get update
            sudo apt-get install -y neovim
            ;;
        arch)
            sudo pacman -S --noconfirm neovim
            ;;
        *)
            echo "Unsupported OS. Please install Neovim manually."
            exit 1
            ;;
    esac

    echo "Neovim installed successfully!"
}

# Deploy dotfiles (symlink config)
deploy() {
    echo "Deploying Neovim configuration..."
    
    # Backup existing config if it exists and is not a symlink
    if [[ -e "$NVIM_CONFIG_DIR" && ! -L "$NVIM_CONFIG_DIR" ]]; then
        echo "Backing up existing config to ${NVIM_CONFIG_DIR}.backup"
        mv "$NVIM_CONFIG_DIR" "${NVIM_CONFIG_DIR}.backup"
    fi

    # Remove existing symlink if present
    if [[ -L "$NVIM_CONFIG_DIR" ]]; then
        rm "$NVIM_CONFIG_DIR"
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$NVIM_CONFIG_DIR")"

    # Create symlink
    ln -s "$DOTFILES_DIR/nvim" "$NVIM_CONFIG_DIR"
    echo "Neovim configuration deployed!"
}

# Sync dotfiles back to this repo
sync() {
    echo "Syncing Neovim configuration back to dotfiles..."
    
    if [[ -L "$NVIM_CONFIG_DIR" ]]; then
        echo "Config is already a symlink, no sync needed."
        return
    fi

    if [[ -d "$NVIM_CONFIG_DIR" ]]; then
        # Remove existing dotfiles nvim directory
        rm -rf "$DOTFILES_DIR/nvim"
        # Copy current config to dotfiles
        cp -r "$NVIM_CONFIG_DIR" "$DOTFILES_DIR/nvim"
        echo "Neovim configuration synced!"
    else
        echo "No Neovim configuration found at $NVIM_CONFIG_DIR"
        exit 1
    fi
}

# Show usage
usage() {
    echo "Usage: $0 {install|deploy|sync}"
    echo ""
    echo "Commands:"
    echo "  install  - Install Neovim for your OS"
    echo "  deploy   - Symlink dotfiles to ~/.config/nvim"
    echo "  sync     - Copy config from ~/.config/nvim back to dotfiles"
    exit 1
}

# Main
case "${1:-}" in
    install)
        install_nvim
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
