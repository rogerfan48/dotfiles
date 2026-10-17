#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/lib/ui.sh"

OS=$(uname -s)
step "Detected OS: $OS"
DOTFILES_DIR="$HOME/.dotfiles"

# Machine-local files (gitignored) must exist in-repo before linking them out.
# Pull a pre-existing real ~/<file> into the repo so its content is preserved.
migrate_local() {
    [[ ! -e "$DOTFILES_DIR/$1" && -f "$HOME/$1" && ! -L "$HOME/$1" ]] && mv "$HOME/$1" "$DOTFILES_DIR/$1"
}
migrate_local .zshrc.local
migrate_local .gitconfig.local

# .gitconfig.local is required (git identity), so seed a placeholder if still absent.
GITCONFIG_LOCAL_SEEDED=false
if [[ ! -e "$DOTFILES_DIR/.gitconfig.local" ]]; then
    printf '[user]\n    name = Your Name\n    email = you@example.com\n' > "$DOTFILES_DIR/.gitconfig.local"
    GITCONFIG_LOCAL_SEEDED=true
fi

declare -A FILES_TO_LINK
if [[ "$OS" == "Darwin" ]]; then # macOS
    FILES_TO_LINK=(
        [".zshrc"]="$HOME/.zshrc"
        [".zshrc.local"]="$HOME/.zshrc.local"
        [".p10k.zsh"]="$HOME/.p10k.zsh"
        [".tmux.conf"]="$HOME/.tmux.conf"
        # [".wezterm.lua"]="$HOME/.wezterm.lua"
        [".config/ghostty/config"]="$HOME/.config/ghostty/config"
        [".hammerspoon"]="$HOME/.hammerspoon"
        ["nvim"]="$HOME/.config/nvim"
        [".config/stylua.toml"]="$HOME/.config/stylua.toml"
        [".config/pylintrc"]="$HOME/.config/pylintrc"
        [".config/black/pyproject.toml"]="$HOME/.config/black/pyproject.toml"
        [".config/marksman/config.toml"]="$HOME/.config/marksman/config.toml"
        [".config/latexmk/latexmkrc"]="$HOME/.config/latexmk/latexmkrc"
        [".config/yamllint/config"]="$HOME/.config/yamllint/config"
        [".config/.gemini/settings.json"]="$HOME/.gemini/settings.json"
        [".prettierrc"]="$HOME/.prettierrc"
        ["eslint.config.mjs"]="$HOME/eslint.config.mjs"
        [".gitconfig"]="$HOME/.gitconfig"
        [".gitignore_global"]="$HOME/.gitignore_global"
        [".gitconfig.local"]="$HOME/.gitconfig.local"
        [".config/lazygit/config.yml"]="$HOME/Library/Application Support/lazygit/config.yml"
    )
elif [[ "$OS" == "Linux" ]]; then # Linux
    FILES_TO_LINK=(
        [".zshrc"]="$HOME/.zshrc"
        [".zshrc.local"]="$HOME/.zshrc.local"
        [".p10k.zsh"]="$HOME/.p10k.zsh"
        [".tmux.conf"]="$HOME/.tmux.conf"
        # [".wezterm.lua"]="$HOME/.wezterm.lua"
        [".config/ghostty/config"]="$HOME/.config/ghostty/config"
        ["nvim"]="$HOME/.config/nvim"
        [".config/stylua.toml"]="$HOME/.config/stylua.toml"
        [".config/pylintrc"]="$HOME/.config/pylintrc"
        [".config/black/pyproject.toml"]="$HOME/.config/black/pyproject.toml"
        [".config/marksman/config.toml"]="$HOME/.config/marksman/config.toml"
        [".config/latexmk/latexmkrc"]="$HOME/.config/latexmk/latexmkrc"
        [".config/yamllint/config"]="$HOME/.config/yamllint/config"
        [".config/.gemini/settings.json"]="$HOME/.gemini/settings.json"
        [".prettierrc"]="$HOME/.prettierrc"
        ["eslint.config.mjs"]="$HOME/eslint.config.mjs"
        [".gitconfig"]="$HOME/.gitconfig"
        [".gitignore_global"]="$HOME/.gitignore_global"
        [".gitconfig.local"]="$HOME/.gitconfig.local"
        [".config/lazygit/config.yml"]="$HOME/.config/lazygit/config.yml"
    )
else
    err "Unsupported OS: $OS"
    exit 1
fi

LINK_WIDTH=0
for file in "${!FILES_TO_LINK[@]}"; do
    l="${FILES_TO_LINK[$file]}"
    (( ${#l} > LINK_WIDTH )) && LINK_WIDTH=${#l}
done

link_line() {  # green check, aligned link, dim arrow + target
    printf '  %s✓%s %-*s %s→ %s%s\n' \
        "$C_GREEN" "$C_RESET" "$LINK_WIDTH" "$1" "$C_DIM" "$2" "$C_RESET"
}

# Sort each entry: already linked (nothing to do), new, or something in the way
LINKED=() NEW=() CONFLICT=()
step "Checking existing links"
for file in "${!FILES_TO_LINK[@]}"; do
    target="${DOTFILES_DIR}/$file"
    link="${FILES_TO_LINK[$file]}"

    if [[ ! -e "$target" ]]; then
        warn "Target '$target' does not exist, skipping"
        continue
    fi

    if [[ -L "$link" && "$(readlink "$link")" == "$target" ]]; then
        LINKED+=("$file")
    elif [[ -e "$link" || -L "$link" ]]; then
        CONFLICT+=("$file")
    else
        NEW+=("$file")
    fi
done

print_pending() {  # dim bullet, aligned link → target
    printf '  %s• %-*s → %s%s\n' "$C_DIM" "$LINK_WIDTH" "${FILES_TO_LINK[$1]}" "$DOTFILES_DIR/$1" "$C_RESET"
}

[[ ${#LINKED[@]} -gt 0 ]] && skip "${#LINKED[@]} links already in place"
TODO=("${NEW[@]}")
if [[ ${#CONFLICT[@]} -gt 0 ]]; then
    warn "These paths are in the way; files and folders are kept as <path>.bak-<time>:"
    for file in "${CONFLICT[@]}"; do print_pending "$file"; done
    if ask "Replace them with links?" y; then
        TODO+=("${CONFLICT[@]}")
    else
        skip "Keeping them"
    fi
fi

if [[ ${#TODO[@]} -eq 0 ]]; then
    ok "Nothing new to link"
else
    step "Creating symbolic links"
    backup_suffix="bak-$(date +%Y%m%d-%H%M%S)"
    for file in "${TODO[@]}"; do
        target="${DOTFILES_DIR}/$file"
        link="${FILES_TO_LINK[$file]}"
        mkdir -p "$(dirname "$link")"
        if [[ -L "$link" ]]; then
            rm -f "$link" # a link to somewhere else: nothing to keep
        elif [[ -e "$link" ]]; then
            mv "$link" "$link.$backup_suffix" && warn "Kept the old one as $link.$backup_suffix"
        fi
        ln -s "$target" "$link"
        link_line "$link" "$target"
    done
    ok "All symbolic links created"
fi

if [[ "$GITCONFIG_LOCAL_SEEDED" == true ]]; then
    warn "Seeded .gitconfig.local with a placeholder identity"
    warn "→ Set your git identity before committing: edit ~/.dotfiles/.gitconfig.local (name & email)"
fi
