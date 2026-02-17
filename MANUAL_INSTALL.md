# Manual Installation

## 1. Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## 2. Packages
```bash
brew install fzf coreutils jenv
brew install --cask font-jetbrains-mono-nerd-font ghostty
```

## 3. Clone dotfiles
```bash
git clone <your-repo-url> ~/Documents/Dev/Git/dotfiles
```

## 4. Copy configs

### Zsh
```bash
cp ~/Documents/Dev/Git/dotfiles/zsh/.zshrc ~/.zshrc
cp ~/Documents/Dev/Git/dotfiles/zsh/.zprofile ~/.zprofile
cp ~/Documents/Dev/Git/dotfiles/zsh/.p10k.zsh ~/.p10k.zsh
```

### Ghostty
```bash
mkdir -p ~/.config/ghostty
cp ~/Documents/Dev/Git/dotfiles/ghostty/config ~/.config/ghostty/config
```

### OpenCode
```bash
mkdir -p ~/.config/opencode/{agents,plugins}
cp ~/Documents/Dev/Git/dotfiles/opencode/opencode.json ~/.config/opencode/
cp ~/Documents/Dev/Git/dotfiles/opencode/config.json ~/.config/opencode/
cp ~/Documents/Dev/Git/dotfiles/opencode/AGENTS.md ~/.config/opencode/
cp ~/Documents/Dev/Git/dotfiles/opencode/package.json ~/.config/opencode/
cp ~/Documents/Dev/Git/dotfiles/opencode/agents/*.md ~/.config/opencode/agents/
cp ~/Documents/Dev/Git/dotfiles/opencode/plugins/*.js ~/.config/opencode/plugins/
(cd ~/.config/opencode && bun install)
```

### Secrets
```bash
cp ~/Documents/Dev/Git/dotfiles/zsh/.env.secrets.template ~/.env.secrets
chmod 600 ~/.env.secrets
# Edit ~/.env.secrets and fill in your keys
```

### Misc
```bash
touch ~/.hushlogin
```

## 5. Open a new terminal
- Zinit auto-installs itself and all plugins on first launch
- Powerlevel10k wizard will run -- follow the prompts

## If the machine has Oh My Zsh
Before step 4, back up or remove it:
```bash
mv ~/.zshrc ~/.zshrc.ohmyzsh.bak
rm -rf ~/.oh-my-zsh
```
