#!/bin/bash

# VS Code installation and dotfiles management script
# Supports: macOS, Ubuntu/Debian, Arch Linux, WSL

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Detect OS and set VS Code config path
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

get_vscode_config_dir() {
    local os=$(detect_os)
    case $os in
        macos)
            echo "$HOME/Library/Application Support/Code/User"
            ;;
        *)
            echo "$HOME/.config/Code/User"
            ;;
    esac
}

# Install VS Code
install_vscode() {
    local os=$(detect_os)
    echo "Detected OS: $os"
    echo "Installing VS Code..."

    case $os in
        macos)
            if ! command -v brew &> /dev/null; then
                echo "Homebrew not found. Please install Homebrew first."
                exit 1
            fi
            brew install --cask visual-studio-code
            ;;
        ubuntu|wsl)
            # Add Microsoft repository
            wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
            sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
            sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
            rm -f packages.microsoft.gpg
            sudo apt-get update
            sudo apt-get install -y code
            ;;
        arch)
            # Install from AUR using yay or paru
            if command -v yay &> /dev/null; then
                yay -S --noconfirm visual-studio-code-bin
            elif command -v paru &> /dev/null; then
                paru -S --noconfirm visual-studio-code-bin
            else
                echo "Please install yay or paru to install VS Code from AUR"
                echo "Or install manually from: https://code.visualstudio.com/"
                exit 1
            fi
            ;;
        *)
            echo "Unsupported OS. Please install VS Code manually."
            echo "Visit: https://code.visualstudio.com/"
            exit 1
            ;;
    esac

    echo "VS Code installed successfully!"
}

# Install extensions from extensions.txt
install_extensions() {
    echo "Installing VS Code extensions..."
    
    if [[ ! -f "$DOTFILES_DIR/vscode/extensions.txt" ]]; then
        echo "No extensions.txt found"
        return
    fi

    while IFS= read -r extension || [[ -n "$extension" ]]; do
        if [[ -n "$extension" && ! "$extension" =~ ^# ]]; then
            echo "Installing: $extension"
            code --install-extension "$extension" --force || true
        fi
    done < "$DOTFILES_DIR/vscode/extensions.txt"
    
    echo "Extensions installed!"
}

# Deploy dotfiles (symlink config)
deploy() {
    local config_dir=$(get_vscode_config_dir)
    echo "Deploying VS Code configuration to $config_dir..."
    
    mkdir -p "$config_dir"

    # Deploy settings.json
    local settings_file="$config_dir/settings.json"
    if [[ -e "$settings_file" && ! -L "$settings_file" ]]; then
        echo "Backing up existing settings.json"
        mv "$settings_file" "${settings_file}.backup"
    fi
    if [[ -L "$settings_file" ]]; then
        rm "$settings_file"
    fi
    ln -s "$DOTFILES_DIR/vscode/settings.json" "$settings_file"
    echo "settings.json deployed!"

    # Deploy keybindings.json
    local keybindings_file="$config_dir/keybindings.json"
    if [[ -e "$keybindings_file" && ! -L "$keybindings_file" ]]; then
        echo "Backing up existing keybindings.json"
        mv "$keybindings_file" "${keybindings_file}.backup"
    fi
    if [[ -L "$keybindings_file" ]]; then
        rm "$keybindings_file"
    fi
    ln -s "$DOTFILES_DIR/vscode/keybindings.json" "$keybindings_file"
    echo "keybindings.json deployed!"

    # Install extensions
    install_extensions

    echo "VS Code configuration deployed!"
}

# Sync dotfiles back to this repo
sync() {
    local config_dir=$(get_vscode_config_dir)
    echo "Syncing VS Code configuration back to dotfiles..."
    
    # Sync settings.json
    local settings_file="$config_dir/settings.json"
    if [[ -L "$settings_file" ]]; then
        echo "settings.json is already a symlink, no sync needed."
    elif [[ -f "$settings_file" ]]; then
        cp "$settings_file" "$DOTFILES_DIR/vscode/settings.json"
        echo "settings.json synced!"
    fi

    # Sync keybindings.json
    local keybindings_file="$config_dir/keybindings.json"
    if [[ -L "$keybindings_file" ]]; then
        echo "keybindings.json is already a symlink, no sync needed."
    elif [[ -f "$keybindings_file" ]]; then
        cp "$keybindings_file" "$DOTFILES_DIR/vscode/keybindings.json"
        echo "keybindings.json synced!"
    fi

    # Export installed extensions
    echo "Exporting installed extensions..."
    code --list-extensions > "$DOTFILES_DIR/vscode/extensions.txt"
    echo "extensions.txt updated!"
}

# Show usage
usage() {
    echo "Usage: $0 {install|deploy|sync|extensions}"
    echo ""
    echo "Commands:"
    echo "  install     - Install VS Code for your OS"
    echo "  deploy      - Symlink dotfiles and install extensions"
    echo "  sync        - Copy configs back to dotfiles and export extensions"
    echo "  extensions  - Install extensions from extensions.txt"
    exit 1
}

# Main
case "${1:-}" in
    install)
        install_vscode
        ;;
    deploy)
        deploy
        ;;
    sync)
        sync
        ;;
    extensions)
        install_extensions
        ;;
    *)
        usage
        ;;
esac
