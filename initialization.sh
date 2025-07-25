#!/bin/bash

install_jetbrainsmono_font() {
    local font_url="https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip"
    local temp_zip="/tmp/JetBrainsMono.zip"
    local temp_dir="/tmp/JetBrainsMono"

    echo "### Downloading JetBrainsMono Nerd Font..."
    curl -L "$font_url" -o "$temp_zip"
    echo "Unzipping font package..."
    rm -rf "$temp_dir"
    unzip -q "$temp_zip" -d "$temp_dir"

    if [[ "$OS" == "Darwin" ]]; then # macOS: copy all .ttf files to ~/Library/Fonts
        echo "Installing JetBrainsMono Nerd Font to macOS Fonts..."
        mkdir -p "$HOME/Library/Fonts"
        find "$temp_dir" -type f -iname "*.ttf" -exec cp {} "$HOME/Library/Fonts/" \;
    elif [[ "$OS" == "Linux" ]]; then # Linux: copy to ~/.local/share/fonts and update font cache
        echo "Installing JetBrainsMono Nerd Font to Linux fonts directory..."
        mkdir -p "$HOME/.local/share/fonts"
        find "$temp_dir" -type f -iname "*.ttf" -exec cp {} "$HOME/.local/share/fonts/" \;
        fc-cache -f >/dev/null 2>&1
    else
        echo "Font installation not supported for OS: $OS"
    fi
    echo "JetBrainsMono Nerd Font installation complete."
}

install_jf_openhuninn_font() {
    local font_url="https://github.com/justfont/open-huninn-font/releases/download/v2.0/jf-openhuninn-2.0.ttf"
    local temp_file="/tmp/jf-openhuninn-2.0.ttf"

    echo "### Downloading jf-openhuninn-2.0 font..."
    curl -L "$font_url" -o "$temp_file"

    if [[ "$OS" == "Darwin" ]]; then
        echo "Installing jf-openhuninn-2.0 font to macOS Fonts..."
        mkdir -p "$HOME/Library/Fonts"
        cp "$temp_file" "$HOME/Library/Fonts/"
    elif [[ "$OS" == "Linux" ]]; then
        echo "Installing jf-openhuninn-2.0 font to Linux fonts directory..."
        mkdir -p "$HOME/.local/share/fonts"
        cp "$temp_file" "$HOME/.local/share/fonts/"
        fc-cache -f >/dev/null 2>&1
    else
        echo "Font installation not supported for OS: $OS"
    fi
    echo "jf-openhuninn-2.0 font installation complete."
}

set_zsh_default() {
    read -r -p "Would you like to set zsh as your default shell? (y/n): " set_zsh
    if [[ "$set_zsh" == "y" ]]; then
        if command -v zsh >/dev/null 2>&1; then
            echo "Setting zsh as the default shell..."
            sudo bash -c "echo $(which zsh) >> /etc/shells" # because `chsh` only accepts shells in /etc/shells
            chsh -s "$(command -v zsh)"
        else
            echo "zsh is not installed. Please install zsh first."
        fi
    else
        echo "Skipping setting default shell to zsh."
    fi
}

if ! command -v git >/dev/null 2>&1; then
    echo "Error: git is not installed. Please install git (e.g., via Homebrew on macOS or apt on Linux) and re-run this script."
    exit 1
fi

read -r -p "This script will install various tools and configure your environment. Do you wish to continue? (y/n): " proceed
if [[ "$proceed" != "y" ]]; then
    echo "Installation aborted."
    exit 1
fi

OS=$(uname -s)
echo "### Detected OS: $OS"

# =======================
# Setup for macOS
# =======================
if [[ "$OS" == "Darwin" ]]; then
    if ! command -v brew >/dev/null 2>&1; then
        echo "Error: Homebrew is not installed. Please install Homebrew and re-run this script."
        exit 1
    fi
    echo "### Setting up environment for macOS..."

    echo "### Updating Homebrew..."
    brew update

    echo "### Installing basic tools: bash"
    brew install bash

    echo "### Installing WezTerm..."
    if brew info --cask wezterm >/dev/null 2>&1; then
        brew install --cask wezterm
    else
        brew install wezterm
    fi

    echo "### Installing \"JetBrainsMono Nerd Font Mono...\""
    if ls "$HOME/Library/Fonts"/*JetBrainsMono*.ttf 1>/dev/null 2>&1; then
        echo "JetBrainsMono Nerd Font is already installed."
    else
        install_jetbrainsmono_font
    fi

    echo "### Installing \"jf-openhuninn-2.0\""
    if ls "$HOME/Library/Fonts"/*jf-openhuninn-2.0*.ttf 1>/dev/null 2>&1; then
        echo "jf-openhuninn-2.0 font is already installed."
    else
        install_jf_openhuninn_font
    fi

    echo "### Installing zsh and oh-my-zsh..."
    brew install zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo "oh-my-zsh is already installed."
    fi

    echo "### Installing powerlevel10k theme..."
    if [[ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    else
        echo "powerlevel10k theme is already installed."
    fi

    echo "Installing zsh plugins: zsh-autosuggestions and zsh-syntax-highlighting..."
    brew install zsh-autosuggestions zsh-syntax-highlighting
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    # !!! Be sure to link and rename plugins' shell script !!!
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        ln -s "$(brew --prefix)/share/zsh-autosuggestions" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        mv "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"
        echo "Created symbolic link for zsh-autosuggestions."
    fi
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        ln -s "$(brew --prefix)/share/zsh-syntax-highlighting" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        mv "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh"
        echo "Created symbolic link for zsh-syntax-highlighting."
    fi

    # Install tmux and tpm if not installed
    echo "### Installing tmux..."
    if ! command -v tmux >/dev/null 2>&1; then
        brew install tmux
    else
        echo "tmux is already installed."
    fi
    echo "### Installing TPM (Tmux Plugin Manager)..."
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    else
        echo "TPM is already installed."
    fi

    echo "Installing additional tools: nvim, bat, cppcheck, fzf, node, pngpaste, lazygit, ripgrep..."
    brew install nvim bat cppcheck fzf node pngpaste lazygit ripgrep

# =======================
# Setup for Linux (Ubuntu)
# =======================
elif [[ "$OS" == "Linux" ]]; then
    echo "### Setting up environment for Linux (Ubuntu)..."

    sudo apt-get update

    echo "### Installing basic tools and dependencies..."
    sudo apt-get install -y bash zsh curl wget git fontconfig \
        unzip python3 python3-pip python3-venv \
        neovim bat cppcheck fzf ripgrep tmux \
        zsh-autosuggestions zsh-syntax-highlighting \
        liblua5.1-0-dev luarocks

    # For bat: create symlink if necessary on Ubuntu
    if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
        # build the symlink in a user-accessible path
        sudo ln -s "$(command -v batcat)" /usr/local/bin/bat
        echo "### Created symlink for bat."
    fi

    echo "### Checking for WezTerm..."
    if ! command -v wezterm >/dev/null 2>&1; then
        echo "### !!! NOTICE: WezTerm is not detected. Please install it from https://wezfurlong.org/wezterm/."
    else
        echo "WezTerm is already installed."
    fi

    echo "### Installing \"JetBrainsMono Nerd Font Mono...\""
    if fc-list | grep -i "JetBrains Mono" >/dev/null 2>&1; then
        echo "JetBrainsMono Nerd Font is already installed."
    else
        install_jetbrainsmono_font
    fi

    echo "### Installing \"jf-openhuninn-2.0\""
    if fc-list | grep -i "jf-openhuninn-2.0" >/dev/null 2>&1; then
        echo "jf-openhuninn-2.0 font is already installed."
    else
        install_jf_openhuninn_font
    fi

    echo "### Installing oh-my-zsh..."
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo "oh-my-zsh is already installed."
    fi

    echo "### Installing powerlevel10k theme..."
    if [[ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    else
        echo "powerlevel10k theme is already installed."
    fi

    echo "### Linking zsh plugins..."
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        ln -s /usr/share/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        mv "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"
        echo "Created symbolic link for zsh-autosuggestions."
    fi
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        ln -s /usr/share/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        mv "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh"
        echo "Created symbolic link for zsh-syntax-highlighting."
    fi

    echo "### Installing TPM (Tmux Plugin Manager)..."
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    else
        echo "TPM is already installed."
    fi

    echo "### Installing Node.js via nvm..."
    if ! command -v nvm >/dev/null 2>&1; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        # make nvm available in the current shell session
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi
    nvm install --lts
    nvm use --lts
    nvm alias default 'lts/*'

    echo "### Installing Treesitter CLI..."
    npm install -g tree-sitter-cli

    echo "### Installing lazygit from binary..."
    if ! command -v lazygit >/dev/null 2>&1; then
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm lazygit.tar.gz lazygit
    else
        echo "lazygit is already installed."
    fi

    echo "### Installing zoxide..."
    if ! command -v zoxide >/dev/null 2>&1; then
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    else
        echo "zoxide is already installed."
    fi

else
    echo "Unsupported operating system: $OS"
    exit 1
fi

# whether to set zsh as default shell
set_zsh_default

# ----------------------------------------------------------------------
# Finally, call setup_link.sh to create symbolic links for dotfiles
# ----------------------------------------------------------------------
DOTFILES_DIR="$HOME/.dotfiles"
SETUP_LINK_SCRIPT="$DOTFILES_DIR/setup_link.sh"

if [[ -f "$SETUP_LINK_SCRIPT" ]]; then
    echo "Running setup_link.sh to create dotfiles symbolic links..."
    bash "$SETUP_LINK_SCRIPT"
else
    echo "Error: setup_link.sh not found in $DOTFILES_DIR"
fi

echo "Environment initialization complete!"
