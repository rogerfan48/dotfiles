#!/bin/bash

# --- output helpers -------------------------------------------------
if [[ -t 1 ]]; then
    C_RESET=$'\e[0m'; C_BLUE=$'\e[1;34m'; C_GREEN=$'\e[32m'
    C_YELLOW=$'\e[33m'; C_RED=$'\e[1;31m'; C_DIM=$'\e[2m'
fi
step() { printf '%s\n' "${C_BLUE}▶ $*${C_RESET}"; }  # action in progress
ok()   { printf '%s\n' "${C_GREEN}✓ $*${C_RESET}"; }  # done / success
skip() { printf '%s\n' "${C_DIM}• $*${C_RESET}"; }    # nothing to do
warn() { printf '%s\n' "${C_YELLOW}⚠ $*${C_RESET}"; }
err()  { printf '%s\n' "${C_RED}✗ $*${C_RESET}"; }

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
declare -A NEW_FILES_TO_LINK
if [[ "$OS" == "Darwin" ]]; then # macOS
    FILES_TO_LINK=(
        [".zshrc"]="$HOME/.zshrc"
        [".zshrc.local"]="$HOME/.zshrc.local"
        [".p10k.zsh"]="$HOME/.p10k.zsh"
        [".tmux.conf"]="$HOME/.tmux.conf"
        [".wezterm.lua"]="$HOME/.wezterm.lua"
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
        [".wezterm.lua"]="$HOME/.wezterm.lua"
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

OVERWRITE_LINKS=()
NEW_LINKS=()
step "Checking existing links"
for file in "${!FILES_TO_LINK[@]}"; do
    target="${DOTFILES_DIR}/$file"
    link="${FILES_TO_LINK[$file]}"

    if [[ ! -e "$target" ]]; then
        warn "Target '$target' does not exist, skipping"
        continue
    fi

    if [[ -e "$link" || -L "$link" ]]; then
        OVERWRITE_LINKS+=("$(printf '%-*s|%s' "$LINK_WIDTH" "$link" "$target")")
    else
        NEW_LINKS+=("$(printf '%-*s|%s' "$LINK_WIDTH" "$link" "$target")")
        NEW_FILES_TO_LINK+=( ["$file"]=${FILES_TO_LINK["$file"]} )
    fi
done

print_pending() {  # dim bullet, link | target
    local link="${1%%|*}" target="${1##*|}"
    printf '  %s• %s → %s%s\n' "$C_DIM" "$link" "$target" "$C_RESET"
}

if [[ ${#OVERWRITE_LINKS[@]} -eq 0 ]]; then
    skip "No existing links to overwrite"
else
    warn "These links already exist and will be overwritten:"
    for item in "${OVERWRITE_LINKS[@]}"; do print_pending "$item"; done

    printf '%sOverwrite all these links? (y/n): %s' "$C_YELLOW" "$C_RESET"
    read -r answer
    if [[ "$answer" != "y" ]]; then
        if [[ ${#NEW_LINKS[@]} -eq 0 ]]; then
            skip "No new links need to be established"
            ok "No change being made!"
            exit 0
        else
            step "These are new links and will be added:"
            for item in "${NEW_LINKS[@]}"; do print_pending "$item"; done

            printf '%sAdd all these links? (y/n): %s' "$C_YELLOW" "$C_RESET"
            read -r ans
            if [[ "$ans" != "y" ]]; then
                ok "No change being made!"
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

step "Creating symbolic links"
for file in "${!FILES_TO_LINK[@]}"; do
    target="${DOTFILES_DIR}/$file"
    link="${FILES_TO_LINK[$file]}"

    [[ -e "$target" ]] || continue

    link_dir=$(dirname "$link")
    mkdir -p "$link_dir"

    if [[ -d "$link" && ! -L "$link" ]]; then
        warn "Removing existing directory: $link"
        rm -rf "$link"
    fi

    ln -sfn "$target" "$link"
    link_line "$link" "$target"
done

ok "All symbolic links created"

if [[ "$GITCONFIG_LOCAL_SEEDED" == true ]]; then
    warn "Seeded .gitconfig.local with a placeholder identity"
    warn "→ Set your git identity before committing: edit ~/.dotfiles/.gitconfig.local (name & email)"
fi
