#!/bin/bash

OS=$(uname -s)
echo "Detected OS: $OS"
DOTFILES_DIR="$HOME/.dotfiles"

declare -A FILES_TO_LINK
declare -A NEW_FILES_TO_LINK
if [[ "$OS" == "Darwin" ]]; then # macOS
    FILES_TO_LINK=(
        [".zshrc"]="$HOME/.zshrc"
        [".p10k.zsh"]="$HOME/.p10k.zsh"
        [".tmux.conf"]="$HOME/.tmux.conf"
        [".wezterm.lua"]="$HOME/.wezterm.lua"
        ["nvim"]="$HOME/.config/nvim"
        [".stylua.toml"]="$HOME/.config/.stylua.toml"
        [".prettierrc"]="$HOME/.prettierrc"
    )
elif [[ "$OS" == "Linux" ]]; then # Linux
    FILES_TO_LINK=(
        [".zshrc"]="$HOME/.zshrc"
        [".p10k.zsh"]="$HOME/.p10k.zsh"
        [".tmux.conf"]="$HOME/.tmux.conf"
        [".wezterm.lua"]="$HOME/.wezterm.lua"
        ["nvim"]="$HOME/.config/nvim"
        [".stylua.toml"]="$HOME/.config/.stylua.toml"
        [".prettierrc"]="$HOME/.prettierrc"
    )
else
    echo "Unsupported OS: $OS"
    exit 1
fi

OVERWRITE_LINKS=()
NEW_LINKS=()
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
    else
        NEW_LINKS+=("$link -> $target")
        NEW_FILES_TO_LINK+=( ["$file"]=${FILES_TO_LINK["$file"]} )
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
        if [[ ${#NEW_LINKS[@]} -eq 0 ]]; then
            echo "No new links need to be established."
            echo "No change being made!"
            exit 0
        else
            echo "The following are new links and will be added:"
            for item in "${NEW_LINKS[@]}"; do
                echo "  $item"
            done

            echo -n "Do you want to add all these links? (y/n): "
            read -r ans
            if [[ "$ans" != "y" ]]; then
                echo "No change being made!"
                exit 0
            else
                FILES_TO_LINK=()
                for key in "${!NEW_FILES_TO_LINK[@]}"; do
                    FILES_TO_LINK["$key"]="${NEW_FILES_TO_LINK["$key"]}"
                done
            fi
        fi
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

    ln -sf "$target" "$link"
    echo "Linked: $link -> $target"
done

echo "All symbolic links created!"
