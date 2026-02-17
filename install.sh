#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Dotfiles install from: $DOTFILES_DIR"

# ── Homebrew ───────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ── Brew packages ──────────────────────────────────────────────────
echo "==> Installing brew packages..."
brew install --cask font-jetbrains-mono-nerd-font
brew install --cask ghostty
brew install fzf coreutils jenv

# ── Copy files ─────────────────────────────────────────────────────
echo "==> Installing config files..."

copy_file() {
  local src="$1"
  local dst="$2"

  if [ -f "$dst" ]; then
    echo "  Backing up existing $dst -> ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi

  cp "$src" "$dst"
  echo "  Installed $dst"
}

# Zsh
copy_file "$DOTFILES_DIR/zsh/.zshrc"    "$HOME/.zshrc"
copy_file "$DOTFILES_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
copy_file "$DOTFILES_DIR/zsh/.zprofile" "$HOME/.zprofile"

# Ghostty
mkdir -p "$HOME/.config/ghostty"
copy_file "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"

# OpenCode
mkdir -p "$HOME/.config/opencode/agents"
mkdir -p "$HOME/.config/opencode/plugins"
copy_file "$DOTFILES_DIR/opencode/opencode.json" "$HOME/.config/opencode/opencode.json"
copy_file "$DOTFILES_DIR/opencode/config.json"   "$HOME/.config/opencode/config.json"
copy_file "$DOTFILES_DIR/opencode/AGENTS.md"      "$HOME/.config/opencode/AGENTS.md"
copy_file "$DOTFILES_DIR/opencode/package.json"   "$HOME/.config/opencode/package.json"
cp "$DOTFILES_DIR/opencode/agents/"*.md "$HOME/.config/opencode/agents/"
echo "  Installed opencode agents"
cp "$DOTFILES_DIR/opencode/plugins/"*.js "$HOME/.config/opencode/plugins/"
echo "  Installed opencode plugins"

# Install opencode plugin dependencies
echo "==> Installing opencode plugin dependencies..."
(cd "$HOME/.config/opencode" && bun install 2>/dev/null || npm install 2>/dev/null || echo "  Warning: could not install opencode deps, install bun or npm first")

# Hushlogin
touch "$HOME/.hushlogin"

# ── Secrets ────────────────────────────────────────────────────────
if [ ! -f "$HOME/.env.secrets" ]; then
  cp "$DOTFILES_DIR/zsh/.env.secrets.template" "$HOME/.env.secrets"
  chmod 600 "$HOME/.env.secrets"
  echo "==> Created ~/.env.secrets from template -- fill in your keys!"
else
  echo "==> ~/.env.secrets already exists, skipping"
fi

# ── Done ───────────────────────────────────────────────────────────
echo ""
echo "==> Done! Open a new terminal to start using the setup."
echo "    Zinit will auto-install plugins on first launch."
echo "    If p10k wizard doesn't start, run: p10k configure"
echo "    OpenCode config installed to ~/.config/opencode/"
