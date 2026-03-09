#!/bin/bash

# QMK Keyboard firmware installation and dotfiles management script
# Supports: macOS, Ubuntu/Debian, Arch Linux, WSL

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
QMK_HOME="$HOME/qmk_firmware"

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

# Install QMK
install_qmk() {
    local os=$(detect_os)
    echo "Detected OS: $os"
    echo "Installing QMK firmware tools..."

    case $os in
        macos)
            if ! command -v brew &> /dev/null; then
                echo "Homebrew not found. Please install Homebrew first."
                exit 1
            fi
            brew install qmk/qmk/qmk
            ;;
        ubuntu|wsl)
            # Install dependencies
            sudo apt-get update
            sudo apt-get install -y git python3-pip
            
            # Install QMK CLI
            python3 -m pip install --user qmk
            
            # Add to PATH if not already
            if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
                export PATH="$HOME/.local/bin:$PATH"
            fi
            ;;
        arch)
            sudo pacman -S --noconfirm qmk
            ;;
        *)
            echo "Unsupported OS. Please install QMK manually."
            echo "Visit: https://docs.qmk.fm/#/newbs_getting_started"
            exit 1
            ;;
    esac

    # Setup QMK
    echo "Setting up QMK..."
    qmk setup -y || true

    echo "QMK installed successfully!"
    echo ""
    echo "Note: You'll need to configure your specific keyboard."
    echo "Use 'qmk config user.keyboard=<keyboard>' to set your keyboard."
}

# Deploy dotfiles to QMK keymap
deploy() {
    echo "Deploying keyboard configuration..."
    
    if [[ ! -d "$QMK_HOME" ]]; then
        echo "QMK firmware not found at $QMK_HOME"
        echo "Please run '$0 install' first or set QMK_HOME"
        exit 1
    fi

    # Prompt for keyboard and keymap name
    read -p "Enter your keyboard (e.g., planck/rev6): " keyboard
    read -p "Enter your keymap name (e.g., chriswren): " keymap

    local keymap_dir="$QMK_HOME/keyboards/$keyboard/keymaps/$keymap"
    
    # Create keymap directory
    mkdir -p "$keymap_dir"

    # Copy files
    if [[ -f "$DOTFILES_DIR/keyboard/keymap.c" ]]; then
        cp "$DOTFILES_DIR/keyboard/keymap.c" "$keymap_dir/keymap.c"
        echo "keymap.c deployed!"
    fi

    if [[ -f "$DOTFILES_DIR/keyboard/config.h" ]]; then
        cp "$DOTFILES_DIR/keyboard/config.h" "$keymap_dir/config.h"
        echo "config.h deployed!"
    fi

    if [[ -f "$DOTFILES_DIR/keyboard/rules.mk" ]]; then
        cp "$DOTFILES_DIR/keyboard/rules.mk" "$keymap_dir/rules.mk"
        echo "rules.mk deployed!"
    fi

    echo ""
    echo "Keyboard configuration deployed to: $keymap_dir"
    echo ""
    echo "To compile: qmk compile -kb $keyboard -km $keymap"
    echo "To flash:   qmk flash -kb $keyboard -km $keymap"
}

# Sync dotfiles back to this repo
sync() {
    echo "Syncing keyboard configuration back to dotfiles..."
    
    if [[ ! -d "$QMK_HOME" ]]; then
        echo "QMK firmware not found at $QMK_HOME"
        exit 1
    fi

    # Prompt for keyboard and keymap name
    read -p "Enter your keyboard (e.g., planck/rev6): " keyboard
    read -p "Enter your keymap name (e.g., chriswren): " keymap

    local keymap_dir="$QMK_HOME/keyboards/$keyboard/keymaps/$keymap"

    if [[ ! -d "$keymap_dir" ]]; then
        echo "Keymap directory not found: $keymap_dir"
        exit 1
    fi

    # Sync files
    if [[ -f "$keymap_dir/keymap.c" ]]; then
        cp "$keymap_dir/keymap.c" "$DOTFILES_DIR/keyboard/keymap.c"
        echo "keymap.c synced!"
    fi

    if [[ -f "$keymap_dir/config.h" ]]; then
        cp "$keymap_dir/config.h" "$DOTFILES_DIR/keyboard/config.h"
        echo "config.h synced!"
    fi

    if [[ -f "$keymap_dir/rules.mk" ]]; then
        cp "$keymap_dir/rules.mk" "$DOTFILES_DIR/keyboard/rules.mk"
        echo "rules.mk synced!"
    fi

    echo "Keyboard configuration synced!"
}

# Show usage
usage() {
    echo "Usage: $0 {install|deploy|sync}"
    echo ""
    echo "Commands:"
    echo "  install  - Install QMK firmware tools for your OS"
    echo "  deploy   - Copy keyboard config to QMK keymap directory"
    echo "  sync     - Copy config from QMK keymap back to dotfiles"
    echo ""
    echo "Environment variables:"
    echo "  QMK_HOME - Path to QMK firmware (default: ~/qmk_firmware)"
    exit 1
}

# Main
case "${1:-}" in
    install)
        install_qmk
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
