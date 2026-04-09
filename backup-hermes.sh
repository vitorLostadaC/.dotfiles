#!/bin/sh
# Backup and restore script for Hermes data
# Usage:
#   ./backup-hermes.sh backup    # Backup ~/.hermes to ~/.dotfiles/.hermes
#   ./backup-hermes.sh restore   # Restore from ~/.dotfiles/.hermes to ~/.hermes

DOTFILES="$HOME/.dotfiles"
ACTION="$1"

case "$ACTION" in
  backup)
    echo "==> Backing up Hermes data..."
    mkdir -p "$DOTFILES/.hermes"

    # Backup memories
    mkdir -p "$DOTFILES/.hermes/memories"
    cp ~/.hermes/memories/MEMORY.md "$DOTFILES/.hermes/memories/" 2>/dev/null || true
    cp ~/.hermes/memories/USER.md "$DOTFILES/.hermes/memories/" 2>/dev/null || true
    echo "  ✓ memories/"

    # Backup skills (custom ones only - note-taking subdirs)
    mkdir -p "$DOTFILES/.hermes/skills/note-taking"
    cp -r ~/.hermes/skills/note-taking/content-creation-system "$DOTFILES/.hermes/skills/note-taking/" 2>/dev/null || true
    cp -r ~/.hermes/skills/note-taking/obsidian "$DOTFILES/.hermes/skills/note-taking/" 2>/dev/null || true
    echo "  ✓ skills/note-taking/"

    # Backup scripts
    mkdir -p "$DOTFILES/.hermes/scripts"
    cp ~/.hermes/scripts/scrape.py "$DOTFILES/.hermes/scripts/" 2>/dev/null || true
    echo "  ✓ scripts/"

    # Backup config
    cp ~/.hermes/config.yaml "$DOTFILES/.hermes/" 2>/dev/null || true
    echo "  ✓ config.yaml"

    # Backup cron jobs (important scheduled tasks)
    mkdir -p "$DOTFILES/.hermes/cron"
    cp ~/.hermes/cron/*.json "$DOTFILES/.hermes/cron/" 2>/dev/null || true
    echo "  ✓ cron/"

    echo ""
    echo "✅ Hermes backup complete!"
    echo "Commit and push to save in git:"
    echo "  cd ~/.dotfiles && git add -A && git commit -m 'backup: hermes data' && git push"
    ;;

  restore)
    echo "==> Restoring Hermes data..."

    # Restore memories
    cp "$DOTFILES/.hermes/memories/MEMORY.md" ~/.hermes/memories/ 2>/dev/null || true
    cp "$DOTFILES/.hermes/memories/USER.md" ~/.hermes/memories/ 2>/dev/null || true
    echo "  ✓ memories/"

    # Restore skills
    cp -r "$DOTFILES/.hermes/skills/note-taking/"* ~/.hermes/skills/note-taking/ 2>/dev/null || true
    echo "  ✓ skills/"

    # Restore scripts
    cp "$DOTFILES/.hermes/scripts/scrape.py" ~/.hermes/scripts/ 2>/dev/null || true
    echo "  ✓ scripts/"

    # Restore cron
    cp "$DOTFILES/.hermes/cron/"*.json ~/.hermes/cron/ 2>/dev/null || true
    echo "  ✓ cron/"

    echo ""
    echo "✅ Hermes restore complete!"
    ;;

  *)
    echo "Usage: backup-hermes.sh [backup|restore]"
    echo ""
    echo "  backup   - Copy ~/.hermes data to ~/.dotfiles/.hermes"
    echo "  restore - Copy ~/.dotfiles/.hermes data to ~/.hermes"
    exit 1
    ;;
esac
