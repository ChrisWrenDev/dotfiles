#!/bin/bash

# Zsh installation and dotfiles management script
# Supports: macOS, Ubuntu/Debian, Arch Linux, WSL

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZSHRC="$HOME/.zshrc"
STARSHIP_CONFIG="$HOME/.config/starship.toml"

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

# Install zsh and related tools
install_zsh() {
    local os=$(detect_os)
    echo "Detected OS: $os"
    echo "Installing zsh and related tools..."

    case $os in
        macos)
            if ! command -v brew &> /dev/null; then
                echo "Homebrew not found. Please install Homebrew first."
                exit 1
            fi
            brew install zsh starship zsh-autosuggestions zsh-syntax-highlighting
            ;;
        ubuntu|wsl)
            sudo apt-get update
            sudo apt-get install -y zsh
            
            # Install Starship
            curl -sS https://starship.rs/install.sh | sh -s -- -y
            
            # Install zsh plugins
            if [[ ! -d "$HOME/.zsh/zsh-autosuggestions" ]]; then
                git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.zsh/zsh-autosuggestions"
            fi
            if [[ ! -d "$HOME/.zsh/zsh-syntax-highlighting" ]]; then
                git clone https://github.com/zsh-users/zsh-syntax-highlighting "$HOME/.zsh/zsh-syntax-highlighting"
            fi
            ;;
        arch)
            sudo pacman -S --noconfirm zsh starship zsh-autosuggestions zsh-syntax-highlighting
            ;;
        *)
            echo "Unsupported OS. Please install zsh manually."
            exit 1
            ;;
    esac

    # Set zsh as default shell
    if [[ "$SHELL" != *"zsh"* ]]; then
        echo "Setting zsh as default shell..."
        chsh -s "$(which zsh)"
    fi

    echo "zsh installed successfully!"
}

# Deploy dotfiles (symlink config)
deploy() {
    echo "Deploying zsh configuration..."
    
    # Deploy .zshrc
    if [[ -e "$ZSHRC" && ! -L "$ZSHRC" ]]; then
        echo "Backing up existing .zshrc to ${ZSHRC}.backup"
        mv "$ZSHRC" "${ZSHRC}.backup"
    fi
    if [[ -L "$ZSHRC" ]]; then
        rm "$ZSHRC"
    fi
    ln -s "$DOTFILES_DIR/zsh/.zshrc" "$ZSHRC"
    echo ".zshrc deployed!"

    # Deploy starship.toml
    mkdir -p "$(dirname "$STARSHIP_CONFIG")"
    if [[ -e "$STARSHIP_CONFIG" && ! -L "$STARSHIP_CONFIG" ]]; then
        echo "Backing up existing starship.toml to ${STARSHIP_CONFIG}.backup"
        mv "$STARSHIP_CONFIG" "${STARSHIP_CONFIG}.backup"
    fi
    if [[ -L "$STARSHIP_CONFIG" ]]; then
        rm "$STARSHIP_CONFIG"
    fi
    ln -s "$DOTFILES_DIR/zsh/starship.toml" "$STARSHIP_CONFIG"
    echo "starship.toml deployed!"

    echo "zsh configuration deployed!"
}

# Sync dotfiles back to this repo
sync() {
    echo "Syncing zsh configuration back to dotfiles..."
    
    # Sync .zshrc
    if [[ -L "$ZSHRC" ]]; then
        echo ".zshrc is already a symlink, no sync needed."
    elif [[ -f "$ZSHRC" ]]; then
        cp "$ZSHRC" "$DOTFILES_DIR/zsh/.zshrc"
        echo ".zshrc synced!"
    else
        echo "No .zshrc found at $ZSHRC"
    fi

    # Sync starship.toml
    if [[ -L "$STARSHIP_CONFIG" ]]; then
        echo "starship.toml is already a symlink, no sync needed."
    elif [[ -f "$STARSHIP_CONFIG" ]]; then
        cp "$STARSHIP_CONFIG" "$DOTFILES_DIR/zsh/starship.toml"
        echo "starship.toml synced!"
    else
        echo "No starship.toml found at $STARSHIP_CONFIG"
    fi
}

# Show usage
usage() {
    echo "Usage: $0 {install|deploy|sync}"
    echo ""
    echo "Commands:"
    echo "  install  - Install zsh, starship, and plugins for your OS"
    echo "  deploy   - Symlink dotfiles to ~/.zshrc and ~/.config/starship.toml"
    echo "  sync     - Copy configs back to dotfiles"
    exit 1
}

# Main
case "${1:-}" in
    install)
        install_zsh
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
