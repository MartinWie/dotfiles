# Enable Powerlevel10k instant prompt (must stay at the top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── Zinit ──────────────────────────────────────────────────────────
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Auto-install zinit if missing
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# ── Plugins ────────────────────────────────────────────────────────
# Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-history-substring-search

# Key bindings for history substring search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Load completions (cached, revalidates every 24h)
autoload -Uz compinit
if [[ -z "$ZSH_COMPDUMP" ]]; then
  ZSH_COMPDUMP="${ZDOTDIR:-$HOME}/.zcompdump-${SHORT_HOST}-${ZSH_VERSION}"
fi
if [[ "$ZSH_COMPDUMP"(#qNmh-24) ]]; then
  compinit -C -d "$ZSH_COMPDUMP"
else
  compinit -d "$ZSH_COMPDUMP"
fi
zinit cdreplay -q

# ── Powerlevel10k config ──────────────────────────────────────────
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ── History ────────────────────────────────────────────────────────
HISTFILE=~/.histfile
HISTSIZE=9999999999
SAVEHIST=9999999999
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# ── GPG (lazy-loaded on first command) ─────────────────────────────
_gpg_init() {
  export GPG_TTY=$(tty)
  gpgconf --launch gpg-agent
  add-zsh-hook -d preexec _gpg_init
}
autoload -Uz add-zsh-hook
add-zsh-hook preexec _gpg_init

# ── Aliases ────────────────────────────────────────────────────────
alias ls='ls --color=auto'
alias lsa='ls --color=auto -a'
alias ll='ls -all'

alias sf='cd ~/Documents/Dev/Git/sherlock && python sherlock --print-found'

alias python=/opt/homebrew/bin/python3.11
alias pip=pip3
alias idea_dev='cd /Applications/  && pydo -q -e Dev open "IntelliJ\ IDEA\ CE.app"'

alias ip_local="ifconfig -a | grep \"inet \""
alias ip_inet="dig +short myip.opendns.com @resolver1.opendns.com"

alias opencode_main='opencode ~/Documents/Dev/Git'

alias merge='git fetch && git merge && currentBranch=$(git rev-parse --abbrev-ref HEAD) && git checkout master && git pull && git checkout $currentBranch && git merge master'
alias tp='bash testAndPush.sh'

# ── Environment / PATH ────────────────────────────────────────────
export JAVA_HOME=$HOME/Library/Java/JavaVirtualMachines/openjdk-21.0.2/Contents/Home

# jenv (lazy-loaded)
export PATH="$HOME/.jenv/shims:$HOME/.jenv/bin:$PATH"
jenv() {
  unfunction jenv
  eval "$(command jenv init -)"
  jenv "$@"
}

# opencode
export PATH=$HOME/.opencode/bin:$PATH

. "$HOME/.local/bin/env"

# ── Secrets (API keys, tokens) ────────────────────────────────────
[[ -f ~/.env.secrets ]] && source ~/.env.secrets
