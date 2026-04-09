#!/bin/sh
set -e

DOTFILES="$HOME/.dotfiles"

echo "==> Installing Homebrew if needed..."
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "==> Installing Homebrew packages..."
brew bundle --file="$DOTFILES/Brewfile" || true

echo "==> Creating config symlinks..."
mkdir -p "$HOME/.config"

# Link all configs from ~/.dotfiles/config
for item in "$DOTFILES"/config/*; do
  name=$(basename "$item")
  target="$HOME/.config/$name"

  # Skip certain configs
  case "$name" in
    ghostty|nvim|tmux|git|gh|htop|shell_gpt|zed)
      if [ -e "$target" ] || [ -L "$target" ]; then
        echo "  Skipping $name, already exists"
      else
        ln -s "$item" "$target"
        echo "  Linked $name"
      fi
      ;;
  esac
done

echo "==> Setting up Oh-My-Zsh..."
export ZSH="$HOME/.oh-my-zsh"
if [ ! -d "$ZSH" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Oh-My-Zsh plugins
OMZ_PLUGINS="$ZSH/custom/plugins"
mkdir -p "$OMZ_PLUGINS"

if [ ! -d "$OMZ_PLUGINS/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$OMZ_PLUGINS/zsh-autosuggestions"
fi

if [ ! -d "$OMZ_PLUGINS/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$OMZ_PLUGINS/zsh-syntax-highlighting"
fi

echo "==> Setting up TPM for tmux..."
TMUX_PLUGINS="$HOME/.config/tmux/plugins"
mkdir -p "$TMUX_PLUGINS"
if [ ! -d "$TMUX_PLUGINS/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm "$TMUX_PLUGINS/tpm"
fi

echo "==> Installing tmux plugins..."
$TMUX_PLUGINS/tpm/bin/install_plugins

echo "==> Setting up lazy.nvim for Neovim..."
NVIM_LAZY="$HOME/.local/share/nvim/lazy/lazy.nvim"
mkdir -p "$(dirname "$NVIM_LAZY")"
if [ ! -d "$NVIM_LAZY" ]; then
  git clone --filter=blob:none --branch=stable https://github.com/folke/lazy.nvim.git "$NVIM_LAZY"
fi

echo "==> Symlinking shell configs..."
# zshrc
if [ ! -e "$HOME/.zshrc" ]; then
  ln -s "$DOTFILES/.zshrc" "$HOME/.zshrc"
else
  echo "  Skipping .zshrc, already exists"
fi

# local bin
mkdir -p "$HOME/.local/bin"
if [ ! -e "$HOME/.local/bin/env" ]; then
  ln -s "$DOTFILES/.local/bin/env" "$HOME/.local/bin/env"
fi

echo "==> Setting up Hermes config..."
mkdir -p "$HOME/.hermes"
if [ ! -e "$HOME/.hermes/config.yaml" ]; then
  ln -s "$DOTFILES/.hermes/config.yaml" "$HOME/.hermes/config.yaml"
fi

echo ""
echo "========================================"
echo "✅ Dotfiles setup complete!"
echo ""
echo "Next steps:"
echo "  1. Restart your shell or run: source ~/.zshrc"
echo "  2. Set up secrets in ~/.local/bin/env"
echo "  3. Configure your API keys in ~/.hermes/config.yaml"
echo "  4. Run 'tmux' to start tmux, then Ctrl+B I to install plugins"
echo "  5. Open nvim and run :Lazy sync to install plugins"
echo "========================================"
