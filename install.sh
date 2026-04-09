#!/bin/sh
set -e

DOTFILES="$HOME/.dotfiles"
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "==> Installing Homebrew if needed..."
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "==> Installing Homebrew packages..."
brew bundle --file="$DOTFILES/Brewfile" || true

echo "==> Symlinking root config files..."
# Root level configs
ln -sf "$DOTFILES/.gitconfig" "$HOME/.gitconfig"
ln -sf "$DOTFILES/.profile" "$HOME/.profile"
ln -sf "$DOTFILES/.p10k.zsh" "$HOME/.p10k.zsh"
ln -sf "$DOTFILES/.wakatime.cfg" "$HOME/.wakatime.cfg"
ln -sf "$DOTFILES/.zshrc" "$HOME/.zshrc"

echo "==> Creating ~/.config symlinks..."
mkdir -p "$HOME/.config"
for item in "$DOTFILES"/config/*; do
  name=$(basename "$item")
  target="$HOME/.config/$name"
  if [ -e "$target" ] || [ -L "$target" ]; then
    echo "  Skipping $name, already exists"
  else
    ln -s "$item" "$target"
    echo "  Linked $name"
  fi
done

echo "==> Setting up Oh-My-Zsh..."
export ZSH="$HOME/.oh-my-zsh"
if [ ! -d "$ZSH" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Oh-My-Zsh plugins
OMZ_PLUGINS="$ZSH/custom/plugins"
mkdir -p "$OMZ_PLUGINS"
[ ! -d "$OMZ_PLUGINS/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions "$OMZ_PLUGINS/zsh-autosuggestions"
[ ! -d "$OMZ_PLUGINS/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting "$OMZ_PLUGINS/zsh-syntax-highlighting"

echo "==> Setting up TPM for tmux..."
mkdir -p "$HOME/.config/tmux/plugins"
[ ! -d "$HOME/.config/tmux/plugins/tpm" ] && git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"

echo "==> Installing tmux plugins..."
"$HOME/.config/tmux/plugins/tpm/bin/install_plugins"

echo "==> Setting up lazy.nvim for Neovim..."
mkdir -p "$HOME/.local/share/nvim/lazy"
[ ! -d "$HOME/.local/share/nvim/lazy/lazy.nvim" ] && git clone --filter=blob:none --branch=stable https://github.com/folke/lazy.nvim.git "$HOME/.local/share/nvim/lazy/lazy.nvim"

echo "==> Setting up local bin..."
mkdir -p "$HOME/.local/bin"
[ ! -e "$HOME/.local/bin/env" ] && ln -s "$DOTFILES/.local/bin/env" "$HOME/.local/bin/env"

echo "==> Setting up Hermes..."
mkdir -p "$HOME/.hermes"
# Link Hermes config and important data (not secrets)
ln -sf "$DOTFILES/.hermes/config.yaml" "$HOME/.hermes/config.yaml"
ln -sf "$DOTFILES/.hermes/memories" "$HOME/.hermes/memories"
ln -sf "$DOTFILES/.hermes/skills" "$HOME/.hermes/skills"
ln -sf "$DOTFILES/.hermes/scripts" "$HOME/.hermes/scripts"
# Copy (not link) auth.json template - user must fill in their API keys
[ ! -e "$HOME/.hermes/auth.json" ] && cp "$DOTFILES/.hermes/auth.json" "$HOME/.hermes/auth.json"

echo ""
echo "========================================"
echo "✅ Dotfiles setup complete!"
echo ""
echo "Next steps:"
echo "  1. Restart shell or run: source ~/.zshrc"
echo "  2. Fill in API keys:"
echo "     - ~/.hermes/auth.json (OPENROUTER_API_KEY)"
echo "     - ~/.wakatime.cfg (WAKATIME_API_KEY)"
echo "     - ~/.local/bin/env (other secrets)"
echo "  3. In tmux: Ctrl+B I to install plugins"
echo "  4. In nvim: :Lazy sync to install plugins"
echo ""
echo "To backup Hermes data later:"
echo "  ~/.dotfiles/backup-hermes.sh"
echo "========================================"
