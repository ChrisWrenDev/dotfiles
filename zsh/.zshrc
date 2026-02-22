# ======== ALIAS =========

alias x="exit"
alias c="clear"
alias k="kubectl"
alias tf="terraform"

# ======= ZSH OPTIONS ========

setopt AUTOCD              # change directory just by typing its name
setopt PROMPT_SUBST        # enable command substitution in prompt
setopt MENU_COMPLETE       # Automatically highlight first element of completion menu
setopt LIST_PACKED		   # The completion menu takes less space.
setopt AUTO_LIST           # Automatically list choices on ambiguous completion.
setopt HIST_IGNORE_DUPS	   # Do not write events to history that are duplicates of previous events
setopt HIST_FIND_NO_DUPS   # When searching history don't display results already cycled through twice
setopt COMPLETE_IN_WORD    # Complete from both ends of a word.
stty start undef
stty stop undef
setopt noflowcontrol

# history setup
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# ======= PLUGINS ========
#
if [[ "$OSTYPE" == darwin* ]]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ "$OSTYPE" == linux* ]]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  # source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
fi

plugins=(git fzf cp sudo colored-man-pages command-not-found dirhistory)

# ========================

eval "$(fzf --zsh)"

eval "$(starship init zsh)"

eval "$(mise activate zsh)"

# ======= EXPORTS ========

fg="#C9D1D9"
bg="#0D1117"
bg_highlight="#161B22"
hl="#D2A8FF"
blue="#58A6FF"
cyan="#56D4DD"

export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${hl},fg+:${fg},bg+:${bg_highlight},hl+:${hl},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

# FD
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

# BAT
export BAT_THEME=tokyonight_night

# RUST: target + cache directories
export RUSTC_WRAPPER=$(command -v sccache) # sccache

export RUSTUP_HOME=$HOME/rust-cache/rustup

export CARGO_HOME=$HOME/rust-cache/cargo
export CARGO_TARGET_DIR=$HOME/rust-cache/target

export SCCACHE_DIR=$HOME/rust-cache/sccache
export SCCACHE_CACHE_SIZE=50G

# export CARGO_TARGET_DIR=/mnt/ssd/rust-dev-cache/target
# export SCCACHE_DIR=/mnt/ssd/rust-dev-cache/sccache
