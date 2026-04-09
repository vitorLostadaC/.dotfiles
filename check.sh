#!/bin/sh
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check() {
    local desc="$1"
    local cmd="$2"
    if eval "$cmd" >/dev/null 2>&1; then
        echo "${GREEN}✓${NC} $desc"
        return 0
    else
        echo "${RED}✗${NC} $desc"
        return 1
    fi
}

check_symlink() {
    local source="$1"
    local target="$2"
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        echo "${GREEN}✓${NC} Symlink: $target -> $source"
        return 0
    else
        echo "${RED}✗${NC} Symlink missing: $target"
        return 1
    fi
}

echo "========================================"
echo "Dotfiles Health Check"
echo "========================================"
echo ""

errors=0

# Check symlinks
echo "--- Symlinks ---"
check_symlink "$HOME/.dotfiles/.zshrc" "$HOME/.zshrc" || errors=$((errors+1))
check_symlink "$HOME/.dotfiles/.hermes/config.yaml" "$HOME/.hermes/config.yaml" || errors=$((errors+1))
check_symlink "$HOME/.dotfiles/.local/bin/env" "$HOME/.local/bin/env" || errors=$((errors+1))

# Check config dirs
echo ""
echo "--- Config Directories ---"
for config in ghostty nvim tmux git gh htop shell_gpt zed; do
    if [ -e "$HOME/.config/$config" ] || [ -L "$HOME/.config/$config" ]; then
        echo "${GREEN}✓${NC} ~/.config/$config"
    else
        echo "${YELLOW}○${NC} ~/.config/$config (not linked)"
    fi
done

# Check tools
echo ""
echo "--- Tools ---"
for tool in zsh tmux neovim git gh fzf fd bat delta zoxide rg jq curl wget; do
    check "$tool installed" "command -v $tool" || errors=$((errors+1))
done

# Check plugins
echo ""
echo "--- Plugins ---"
check "Oh-My-Zsh" "[ -d "$HOME/.oh-my-zsh" ]" || errors=$((errors+1))
check "zsh-autosuggestions" "[ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]" || errors=$((errors+1))
check "zsh-syntax-highlighting" "[ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]" || errors=$((errors+1))
check "TPM" "[ -d "$HOME/.config/tmux/plugins/tpm" ]" || errors=$((errors+1))
check "lazy.nvim" "[ -d "$HOME/.local/share/nvim/lazy/lazy.nvim" ]" || errors=$((errors+1))

# Check secrets
echo ""
echo "--- Secrets (should exist after setup) ---"
if [ -f "$HOME/.local/bin/env" ] && [ ! -L "$HOME/.local/bin/env" ]; then
    echo "${GREEN}✓${NC} ~/.local/bin/env created"
else
    echo "${YELLOW}○${NC} ~/.local/bin/env not yet created"
fi

if [ -f "$HOME/.hermes/auth.json" ] && grep -q "SET_YOUR" "$HOME/.hermes/auth.json" 2>/dev/null; then
    echo "${YELLOW}○${NC} ~/.hermes/auth.json needs API key configuration"
else
    echo "${GREEN}✓${NC} ~/.hermes/auth.json configured"
fi

echo ""
echo "========================================"
if [ $errors -eq 0 ]; then
    echo "${GREEN}✅ All checks passed!${NC}"
else
    echo "${RED}✗ $errors check(s) failed${NC}"
fi
echo "========================================"
