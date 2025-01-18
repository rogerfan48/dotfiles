#!/bin/bash

OS=$(uname -s)
echo "Detected OS: $OS"
DOTFILES_DIR="$HOME/.dotfiles"

declare -A FILES_TO_LINK
if [[ "$OS" == "Darwin" ]]; then # macOS
    FILES_TO_LINK=(
        [".zshrc"]="$HOME/.zshrc"
        [".rogerrc"]="$HOME/.rogerrc"
        [".p10k.zsh"]="$HOME/.p10k.zsh"
        [".tmux.conf"]="$HOME/.tmux.conf"
        ["nvim"]="$HOME/.config/nvim"
    )
elif [[ "$OS" == "Linux" ]]; then # Linux
    FILES_TO_LINK=(
        [".zshrc"]="$HOME/.zshrc"
        [".rogerrc"]="$HOME/.rogerrc"
        [".p10k.zsh"]="$HOME/.p10k.zsh"
        [".tmux.conf"]="$HOME/.tmux.conf"
        ["nvim"]="$HOME/.config/nvim"
    )
else
    echo "Unsupported OS: $OS"
    exit 1
fi

OVERWRITE_LINKS=()
echo "Checking existing links..."
for file in "${!FILES_TO_LINK[@]}"; do
    target="${DOTFILES_DIR}/$file"
    link="${FILES_TO_LINK[$file]}"

    if [[ ! -e "$target" ]]; then
        echo "Warning: Target file '$target' does not exist. Skipping."
        continue
    fi

    if [[ -e "$link" || -L "$link" ]]; then
        OVERWRITE_LINKS+=("$link -> $target")
    fi
done

if [[ ${#OVERWRITE_LINKS[@]} -eq 0 ]]; then
    echo "No existing links to overwrite. All links will be created without conflict."
else
    echo "The following links already exist and will be overwritten:"
    for item in "${OVERWRITE_LINKS[@]}"; do
        echo "  $item"
    done

    echo -n "Do you want to overwrite all these links? (y/n): "
    read -r answer
    if [[ "$answer" != "y" ]]; then
        echo "No changes made."
        exit 0
    fi
fi

echo "Creating symbolic links..."
for file in "${!FILES_TO_LINK[@]}"; do
    target="${DOTFILES_DIR}/$file"
    link="${FILES_TO_LINK[$file]}"

    if [[ ! -e "$target" ]]; then
        continue
    fi

    if [[ -d "$link" && ! -L "$link" ]]; then
        echo "Removing existing directory: $link"
        rm -rf "$link"
    fi

    echo "Target: $target"
    echo "Link: $link"

    ln -sf "$target" "$link"
    echo "Linked: $link -> $target"
done

echo "All symbolic links created!"
