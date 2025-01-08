#!/bin/sh
mkdir -p ~/.config

ln -s ~/.dotfiles/.zshrc ~/.zshrc

# Link all files and folders from ~/.dotfiles/config
for item in ~/.dotfiles/config/*; do
  target="$HOME/.config/$(basename "$item")"
  
  if [ -e "$target" ] || [ -L "$target" ]; then
    echo "Skipping $target, already exists."
  else
    ln -s "$item" "$target"
    echo "Linked $item to $target"
  fi
done
