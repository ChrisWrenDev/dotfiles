# Dotfiles Installation Scripts

Scripts to install tools and manage dotfiles across different operating systems.

## Supported Operating Systems

- macOS (via Homebrew)
- Ubuntu/Debian (via apt)
- Arch Linux (via pacman)
- WSL (Windows Subsystem for Linux)

## Quick Start

```bash
# Install all tools and deploy dotfiles
./scripts/install-all.sh install
./scripts/install-all.sh deploy

# Or use interactive mode
./scripts/install-all.sh interactive
```

## Available Scripts

| Script | Tool | Config Location |
|--------|------|-----------------|
| `nvim.sh` | Neovim | `~/.config/nvim` |
| `tmux.sh` | tmux + TPM | `~/.tmux.conf` |
| `wezterm.sh` | WezTerm | `~/.wezterm.lua` |
| `zsh.sh` | Zsh + Starship | `~/.zshrc`, `~/.config/starship.toml` |
| `vscode.sh` | VS Code | `~/.config/Code/User/` or `~/Library/Application Support/Code/User/` |
| `keyboard.sh` | QMK Firmware | `~/qmk_firmware/keyboards/<kb>/keymaps/<km>/` |
| `opencode.sh` | OpenCode | `~/.config/opencode` |

## Commands

Each individual script supports three commands:

### install

Installs the tool using the appropriate package manager for your OS.

```bash
./scripts/nvim.sh install
./scripts/zsh.sh install
```

### deploy

Creates symlinks from your home directory to the dotfiles in this repo. Existing configs are backed up with a `.backup` suffix.

```bash
./scripts/nvim.sh deploy
./scripts/zsh.sh deploy
```

### sync

Copies configuration files from their installed location back to this repo. Useful when you've made changes directly to the config files rather than the dotfiles repo.

```bash
./scripts/nvim.sh sync
./scripts/zsh.sh sync
```

## Master Script (install-all.sh)

The `install-all.sh` script can manage all tools at once:

```bash
# Install all tools
./scripts/install-all.sh install

# Deploy all dotfiles
./scripts/install-all.sh deploy

# Sync all configs back to repo
./scripts/install-all.sh sync

# Install/deploy/sync a specific tool
./scripts/install-all.sh install nvim
./scripts/install-all.sh deploy zsh
./scripts/install-all.sh sync vscode

# Interactive mode - select which tools to manage
./scripts/install-all.sh interactive
```

## Workflow

### Setting up a new machine

```bash
# 1. Clone the dotfiles repo
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles

# 2. Install all tools
./scripts/install-all.sh install

# 3. Deploy all configurations
./scripts/install-all.sh deploy

# 4. Restart your shell
exec zsh
```

### Saving changes back to the repo

If you've modified configs directly (e.g., edited `~/.config/nvim/` instead of the repo):

```bash
# Sync changes back
./scripts/install-all.sh sync

# Commit and push
git add -A
git commit -m "Update configs"
git push
```

### Updating on another machine

```bash
cd ~/dotfiles
git pull

# Re-deploy if needed (symlinks should already be in place)
./scripts/install-all.sh deploy
```

## Notes

- **Symlinks**: The `deploy` command creates symlinks, so changes to either location are reflected in both.
- **Backups**: Existing configs are backed up to `<filename>.backup` before creating symlinks.
- **VS Code Extensions**: The `vscode.sh` script also manages extensions via `extensions.txt`.
- **QMK Keyboard**: The `keyboard.sh` script will prompt for your keyboard and keymap name.
- **Zsh Plugins**: On Ubuntu/WSL, zsh plugins are installed to `~/.zsh/`.
