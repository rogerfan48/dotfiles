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
have() { command -v "$1" >/dev/null 2>&1; }

install_jetbrainsmono_font() {
    local font_url="https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip"
    local temp_zip="/tmp/JetBrainsMono.zip"
    local temp_dir="/tmp/JetBrainsMono"

    step "Installing JetBrainsMono Nerd Font"
    curl -L "$font_url" -o "$temp_zip"
    rm -rf "$temp_dir"
    unzip -q "$temp_zip" -d "$temp_dir"

    if [[ "$OS" == "Darwin" ]]; then
        mkdir -p "$HOME/Library/Fonts"
        find "$temp_dir" -type f -iname "*.ttf" -exec cp {} "$HOME/Library/Fonts/" \;
    elif [[ "$OS" == "Linux" ]]; then
        mkdir -p "$HOME/.local/share/fonts"
        find "$temp_dir" -type f -iname "*.ttf" -exec cp {} "$HOME/.local/share/fonts/" \;
        fc-cache -f >/dev/null 2>&1
    else
        warn "Font installation not supported for OS: $OS"
        return
    fi
    ok "JetBrainsMono Nerd Font installed"
}

install_jf_openhuninn_font() {
    local font_url="https://github.com/justfont/open-huninn-font/releases/download/v2.0/jf-openhuninn-2.0.ttf"
    local temp_file="/tmp/jf-openhuninn-2.0.ttf"

    step "Installing jf-openhuninn-2.0 font"
    curl -L "$font_url" -o "$temp_file"

    if [[ "$OS" == "Darwin" ]]; then
        mkdir -p "$HOME/Library/Fonts"
        cp "$temp_file" "$HOME/Library/Fonts/"
    elif [[ "$OS" == "Linux" ]]; then
        mkdir -p "$HOME/.local/share/fonts"
        cp "$temp_file" "$HOME/.local/share/fonts/"
        fc-cache -f >/dev/null 2>&1
    else
        warn "Font installation not supported for OS: $OS"
        return
    fi
    ok "jf-openhuninn-2.0 font installed"
}

set_zsh_default() {
    if [[ "$(basename "${SHELL:-}")" == "zsh" ]]; then
        skip "zsh is already the default shell"
        return
    fi
    read -r -p "Set zsh as your default shell? (y/n): " set_zsh
    [[ "$set_zsh" == "y" ]] || { skip "keeping current default shell"; return; }

    if ! have zsh; then
        warn "zsh is not installed; install it first"
        return
    fi
    step "Setting zsh as the default shell"
    local zsh_path; zsh_path="$(command -v zsh)"
    # chsh only accepts shells listed in /etc/shells
    if ! grep -qxF "$zsh_path" /etc/shells; then
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi
    chsh -s "$zsh_path" && ok "Default shell set to zsh (re-login to apply)"
}

install_neovim() {
    # Install/upgrade Neovim via the official AppImage. Idempotent.
    local NVIM_VERSION="v0.12.4"
    local INSTALL_DIR="$HOME/.nvim"
    local BIN_DIR="$HOME/.local/bin"
    local APPIMAGE_FILE="nvim-linux-x86_64.appimage"
    local APPIMAGE_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${APPIMAGE_FILE}"

    if have nvim && nvim --version | head -n 1 | grep -qF "NVIM ${NVIM_VERSION}"; then
        skip "Neovim ${NVIM_VERSION} already installed"
        return
    fi

    # An nvim managed outside this script (apt/snap/system) — don't clobber it.
    if have nvim && [[ "$(command -v nvim)" != "$BIN_DIR/nvim" ]]; then
        warn "A different Neovim is installed outside this script:"
        warn "  $(command -v nvim)  ($(nvim --version | head -n 1))"
        warn "  Remove it manually, then re-run. Skipping Neovim."
        return
    fi

    step "Installing Neovim ${NVIM_VERSION} (${INSTALL_DIR})"

    if ! have wget; then
        step "Installing wget"
        sudo apt-get install -y wget || { err "Failed to install wget"; return 1; }
    fi

    # Wipe previous script-managed install so upgrades don't keep stale files.
    sudo rm -rf "$INSTALL_DIR/squashfs-root" "$INSTALL_DIR/$APPIMAGE_FILE"
    mkdir -p "$INSTALL_DIR"

    # subshell so the cd stays local and never leaks into the caller
    (
        cd "$INSTALL_DIR" || exit 1
        wget -q "$APPIMAGE_URL" -O "$APPIMAGE_FILE" || { err "Failed to download AppImage"; exit 1; }
        chmod u+x "$APPIMAGE_FILE"
        ./"$APPIMAGE_FILE" --appimage-extract >/dev/null || {
            err "Failed to extract AppImage"
            rm -f "$APPIMAGE_FILE"
            exit 1
        }
        rm -f "$APPIMAGE_FILE"
    ) || return 1

    mkdir -p "$BIN_DIR"
    ln -sf "$INSTALL_DIR/squashfs-root/usr/bin/nvim" "$BIN_DIR/nvim"

    if have nvim; then
        ok "Neovim installed: $(nvim --version | head -n 1)"
    else
        warn "Installed to $BIN_DIR/nvim, but not on PATH — add $BIN_DIR to \$PATH"
    fi

    # TODO: optional plugin deps — sudo apt-get install -y imagemagick xclip pandoc
}

# Rebuild parsers when Neovim changed (stamp-gated). Reinstalls the full set so
# injection-only parsers (html-in-markdown) survive.
rebuild_treesitter_parsers() {
    have nvim || return 0
    local parser_dir="$HOME/.local/share/nvim/lazy/nvim-treesitter/parser"
    [ -d "$parser_dir" ] || return 0 # not set up yet

    local stamp="$parser_dir/.built-for"
    local current
    current="$(nvim --version | head -n 1)"
    [ -f "$stamp" ] && [ "$(cat "$stamp" 2>/dev/null)" == "$current" ] && return 0

    if ! have tree-sitter; then
        warn "tree-sitter CLI missing — skipping parser rebuild (npm i -g tree-sitter-cli, then :TSUpdate)"
        return 0
    fi

    step "Neovim changed (${current}) — rebuilding treesitter parsers"
    if nvim --headless "+lua local ts=require('nvim-treesitter'); local l=ts.get_installed('parsers'); if #l>0 then ts.install(l,{force=true}):wait(600000) end" +qa; then
        echo "$current" >"$stamp"
        ok "Treesitter parser rebuild complete"
    else
        warn "Parser rebuild failed — run :TSUpdate inside nvim"
    fi
}

if ! have git; then
    err "git is not installed. Install git (Homebrew on macOS, apt on Linux) and re-run."
    exit 1
fi

read -r -p "This script will install tools and configure your environment. Continue? (y/n): " proceed
if [[ "$proceed" != "y" ]]; then
    err "Installation aborted."
    exit 1
fi

OS=$(uname -s)
step "Detected OS: $OS"

# =======================
# Setup for macOS
# =======================
if [[ "$OS" == "Darwin" ]]; then
    if ! have brew; then
        err "Homebrew is not installed. Install Homebrew and re-run."
        exit 1
    fi
    step "Setting up environment for macOS"

    step "Updating Homebrew"
    brew update

    step "Installing bash"
    brew install bash

    step "Installing WezTerm"
    if brew info --cask wezterm >/dev/null 2>&1; then
        brew install --cask wezterm
    else
        brew install wezterm
    fi

    if ls "$HOME/Library/Fonts"/*JetBrainsMono*.ttf 1>/dev/null 2>&1; then
        skip "JetBrainsMono Nerd Font already installed"
    else
        install_jetbrainsmono_font
    fi

    if ls "$HOME/Library/Fonts"/*jf-openhuninn-2.0*.ttf 1>/dev/null 2>&1; then
        skip "jf-openhuninn-2.0 font already installed"
    else
        install_jf_openhuninn_font
    fi

    step "Installing zsh"
    brew install zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        step "Installing oh-my-zsh"
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        skip "oh-my-zsh already installed"
    fi

    if [[ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
        step "Installing powerlevel10k theme"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    else
        skip "powerlevel10k theme already installed"
    fi

    step "Installing zsh plugins (autosuggestions, syntax-highlighting)"
    brew install zsh-autosuggestions zsh-syntax-highlighting
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    # link + rename plugin scripts to *.plugin.zsh
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        ln -s "$(brew --prefix)/share/zsh-autosuggestions" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        mv "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"
    fi
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        ln -s "$(brew --prefix)/share/zsh-syntax-highlighting" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        mv "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh"
    fi

    if have tmux; then
        skip "tmux already installed"
    else
        step "Installing tmux"
        brew install tmux
    fi
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        step "Installing TPM (Tmux Plugin Manager)"
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    else
        skip "TPM already installed"
    fi

    step "Installing tools: nvim bat cppcheck fzf fd node pngpaste lazygit ripgrep tree-sitter"
    brew install nvim bat cppcheck fzf fd node pngpaste lazygit ripgrep tree-sitter

    if have pnpm; then
        skip "pnpm already enabled"
    else
        step "Enabling pnpm via corepack"
        corepack enable pnpm
    fi

    # brew's tree-sitter is lib-only; nvim-treesitter (main) needs the CLI → npm.
    if npm ls -g tree-sitter-cli >/dev/null 2>&1; then
        skip "tree-sitter CLI already installed"
    else
        step "Installing tree-sitter CLI"
        npm install -g tree-sitter-cli
    fi

    if have uv; then
        skip "uv already installed"
    else
        step "Installing uv (Python package manager)"
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi

    source "$HOME/.local/bin/env" 2>/dev/null || true
    if uv tool list 2>/dev/null | grep -q '^pylint'; then
        skip "pylint (uv tool) already installed"
    else
        step "Installing pylint via uv"
        uv tool install pylint
    fi

    # Go tooling kept out of Mason (gopls: LSP+format+imports, golangci-lint: lint).
    if have go && have gopls && have golangci-lint; then
        skip "Go toolchain already installed"
    else
        step "Installing Go toolchain (go, gopls, golangci-lint)"
        brew install go gopls golangci-lint ||
            warn "Go tooling install failed — check the Go section in initialization.sh"
    fi

# =======================
# Setup for Linux (Ubuntu)
# =======================
elif [[ "$OS" == "Linux" ]]; then
    step "Setting up environment for Linux (Ubuntu)"

    step "Updating apt and installing base packages"
    sudo apt-get update
    sudo apt-get install -y bash zsh curl wget git fontconfig \
        unzip python3 python3-pip python3-venv \
        bat cppcheck fd-find ripgrep tmux \
        zsh-autosuggestions zsh-syntax-highlighting \
        liblua5.1-0-dev luarocks

    # bat: Ubuntu ships it as `batcat`; expose as `bat`.
    if have batcat && ! have bat; then
        sudo ln -s "$(command -v batcat)" /usr/local/bin/bat
        ok "Created symlink for bat"
    fi
    # fd: Ubuntu ships it as `fdfind`; expose as `fd` for telescope.
    if have fdfind && ! have fd; then
        sudo ln -s "$(command -v fdfind)" /usr/local/bin/fd
        ok "Created symlink for fd"
    fi

    install_neovim

    if have wezterm; then
        skip "WezTerm already installed"
    else
        warn "WezTerm not detected — install from https://wezfurlong.org/wezterm/"
    fi

    if fc-list | grep -i "JetBrains Mono" >/dev/null 2>&1; then
        skip "JetBrainsMono Nerd Font already installed"
    else
        install_jetbrainsmono_font
    fi

    if fc-list | grep -i "jf-openhuninn-2.0" >/dev/null 2>&1; then
        skip "jf-openhuninn-2.0 font already installed"
    else
        install_jf_openhuninn_font
    fi

    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        step "Installing oh-my-zsh"
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        skip "oh-my-zsh already installed"
    fi

    if [[ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
        step "Installing powerlevel10k theme"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    else
        skip "powerlevel10k theme already installed"
    fi

    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        step "Linking zsh-autosuggestions"
        ln -s /usr/share/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        sudo mv "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"
    fi
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        step "Linking zsh-syntax-highlighting"
        ln -s /usr/share/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        sudo mv "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh"
    fi

    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        step "Installing TPM (Tmux Plugin Manager)"
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    else
        skip "TPM already installed"
    fi

    # nvm is a shell function, never on a child shell's PATH — probe the file.
    export NVM_DIR="$HOME/.nvm"
    if [ ! -s "$NVM_DIR/nvm.sh" ]; then
        step "Installing nvm"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    fi
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    if have nvm && [ "$(nvm version 'lts/*')" != "N/A" ]; then
        skip "Node.js LTS already installed ($(nvm version 'lts/*'))"
    else
        step "Installing Node.js LTS"
        nvm install --lts
    fi
    nvm use --lts >/dev/null 2>&1
    nvm alias default 'lts/*' >/dev/null 2>&1

    if have pnpm; then
        skip "pnpm already enabled"
    else
        step "Enabling pnpm via corepack"
        corepack enable pnpm
    fi

    if npm ls -g tree-sitter-cli >/dev/null 2>&1; then
        skip "tree-sitter CLI already installed"
    else
        step "Installing tree-sitter CLI"
        npm install -g tree-sitter-cli
    fi

    # build-essential: needed to compile telescope-fzf-native.
    if dpkg -s build-essential >/dev/null 2>&1; then
        skip "build-essential already installed"
    else
        step "Installing build-essential"
        sudo apt install -y build-essential
    fi

    if have lazygit; then
        skip "lazygit already installed"
    else
        step "Installing lazygit from binary"
        LAZYGIT_VERSION=0.45.2
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm lazygit.tar.gz lazygit
    fi

    if have zoxide; then
        skip "zoxide already installed"
    else
        step "Installing zoxide"
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    fi

    # fzf from git, not apt: Ubuntu's fzf is too old for `fzf --zsh` (needs >= 0.48).
    if [ -d "$HOME/.fzf" ]; then
        skip "fzf already installed ($("$HOME/.fzf/bin/fzf" --version 2>/dev/null | awk '{print $1}'))"
    else
        step "Installing fzf (git)"
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
        "$HOME/.fzf/install" --key-bindings --completion --no-update-rc
    fi

    if have uv; then
        skip "uv already installed"
    else
        step "Installing uv (Python package manager)"
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi

    source "$HOME/.local/bin/env" 2>/dev/null || true
    if uv tool list 2>/dev/null | grep -q '^pylint'; then
        skip "pylint (uv tool) already installed"
    else
        step "Installing pylint via uv"
        uv tool install pylint
    fi

    # Go tooling kept out of Mason (gopls: LSP+format+imports, golangci-lint: lint).
    [[ -d /usr/local/go/bin ]] && export PATH="/usr/local/go/bin:$PATH"
    if have go; then
        skip "Go already installed ($(go version | awk '{print $3}'))"
    else
        step "Installing Go toolchain (latest, linux-amd64)"
        GO_VERSION=$(curl -sSL "https://go.dev/VERSION?m=text" | head -n1)
        curl -sSL "https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tar.gz &&
            sudo rm -rf /usr/local/go &&
            sudo tar -C /usr/local -xzf /tmp/go.tar.gz &&
            rm -f /tmp/go.tar.gz &&
            export PATH="/usr/local/go/bin:$PATH" ||
            warn "Go install failed — check the Go section in initialization.sh"
    fi

    if have gopls; then
        skip "gopls already installed"
    else
        step "Installing gopls into ~/.local/bin"
        GOBIN="$HOME/.local/bin" go install golang.org/x/tools/gopls@latest ||
            warn "gopls install failed — check the Go section in initialization.sh"
    fi
    if have golangci-lint; then
        skip "golangci-lint already installed"
    else
        step "Installing golangci-lint into ~/.local/bin"
        curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/HEAD/install.sh |
            sh -s -- -b "$HOME/.local/bin" ||
            warn "golangci-lint install failed — check the Go section in initialization.sh"
    fi

else
    err "Unsupported operating system: $OS"
    exit 1
fi

# whether to set zsh as default shell
set_zsh_default

# Rebuild treesitter parsers if Neovim was upgraded (needs the tree-sitter CLI above).
rebuild_treesitter_parsers

# ----------------------------------------------------------------------
# Finally, call setup_link.sh to create symbolic links for dotfiles
# ----------------------------------------------------------------------
DOTFILES_DIR="$HOME/.dotfiles"
SETUP_LINK_SCRIPT="$DOTFILES_DIR/setup_link.sh"

if [[ -f "$SETUP_LINK_SCRIPT" ]]; then
    step "Creating dotfiles symbolic links"
    bash "$SETUP_LINK_SCRIPT"
else
    err "setup_link.sh not found in $DOTFILES_DIR"
fi

ok "Environment initialization complete!"
