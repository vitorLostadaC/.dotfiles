#!/bin/sh

# Check if symbolic links are correctly set up
check_symlink() {
    local source="$1"
    local target="$2"
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        echo "\033[0;32mOK: Symlink for $target is correctly set up\033[0m"
    else
        echo "\033[0;31mERROR: Symlink for $target is not correctly set up\033[0m"
        exit 1
    fi
}

# Read symlinks from install.sh and check them
if [ ! -f ~/.dotfiles/install.sh ]; then
    echo "ERROR: install.sh not found in ~/.dotfiles/"
    exit 1
fi

while IFS= read -r line; do
    if [[ $line == ln* ]]; then
        source=$(echo "$line" | awk '{print $3}')
        target=$(echo "$line" | awk '{print $4}')
        
        # Remove potential '~' from the beginning of the paths
        source="${source/#\~/$HOME}"
        target="${target/#\~/$HOME}"
        
        check_symlink "$source" "$target"
    fi
done < ~/.dotfiles/install.sh

echo "========================================"
echo "\033[1;32m✅ All symlinks are correctly set up! 🎉\033[0m"
