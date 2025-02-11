#!/bin/bash

read -r -p "This script will install various tools and configure your environment. Do you wish to continue? (y/n): " proceed
if [[ "$proceed" != "y" ]]; then
    echo "Installation aborted."
    exit 1
fi

OS=$(uname -s)
echo "Detected OS: $OS"

# =======================
# Setup for macOS
# =======================
if [[ "$OS" == "Darwin" ]]; then
    echo "Setting up environment for macOS..."

    # Check and install Homebrew if it is not installed
    if ! command -v brew >/dev/null 2>&1; then
        read -r -p "Homebrew is not installed. Would you like to install Homebrew? (y/n): " install_brew
        if [[ "$install_brew" == "y" ]]; then
            echo "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            cat <<"EOF" >>~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
EOF
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            echo "Homebrew is required. Exiting."
            exit 1
        fi
    else
        echo "Homebrew is already installed."
    fi

    echo "Updating Homebrew..."
    brew update

    echo "Installing basic tools: bash and git..."
    brew install bash git

    echo "Installing WezTerm..."
    if brew info --cask wezterm >/dev/null 2>&1; then
        brew install --cask wezterm
    else
        brew install wezterm
    fi

    echo "Installing \"JetBrainsMono Nerd Font Mono...\""
    brew tap homebrew/cask-fonts
    brew install --cask font-jetbrains-mono-nerd-font

    echo "Installing zsh..."
    brew install zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        echo "Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo "oh-my-zsh is already installed."
    fi

    echo "Installing powerlevel10k theme..."
    if [[ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    else
        echo "powerlevel10k theme is already installed."
    fi

    echo "Installing zsh plugins: zsh-autosuggestions and zsh-syntax-highlighting..."
    brew install zsh-autosuggestions zsh-syntax-highlighting

    # Create symbolic links for the zsh plugins in the oh-my-zsh custom plugins directory
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        ln -s "$(brew --prefix)/share/zsh-autosuggestions" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        echo "Created symbolic link for zsh-autosuggestions."
    fi
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        ln -s "$(brew --prefix)/share/zsh-syntax-highlighting" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        echo "Created symbolic link for zsh-syntax-highlighting."
    fi

    echo "Installing additional tools: nvim, bat, cppcheck, dart, fzf, node, pngpaste, lazygit, ripgrep..."
    brew install nvim bat cppcheck dart fzf node pngpaste lazygit ripgrep

# =======================
# Setup for Linux (Ubuntu)
# =======================
elif [[ "$OS" == "Linux" ]]; then
    echo "Setting up environment for Linux (Ubuntu)..."

    sudo apt-get update

    echo "Installing basic tools: bash, git, zsh, neovim, bat, cppcheck, dart, fzf, nodejs, lazygit, ripgrep..."
    sudo apt-get install -y bash git zsh neovim bat cppcheck dart fzf nodejs lazygit ripgrep

    # Create a symlink for bat if it is installed as batcat
    if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
        sudo ln -s "$(command -v batcat)" /usr/local/bin/bat
        echo "Created symlink for bat."
    fi

    # Check for WezTerm; if not found, prompt the user to install it manually
    echo "Checking for WezTerm..."
    if ! command -v wezterm >/dev/null 2>&1; then
        echo "WezTerm is not detected. Please install it from https://wezfurlong.org/wezterm/."
    else
        echo "WezTerm is already installed."
    fi

    echo "Checking for JetBrainsMono Nerd Font Mono..."
    if ! fc-list | grep -i "JetBrains Mono" >/dev/null 2>&1; then
        echo "Installing JetBrainsMono Nerd Font Mono..."
        sudo apt-get install -y fonts-jetbrains-mono
    else
        echo "JetBrainsMono Nerd Font Mono is already installed."
    fi

    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        echo "Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo "oh-my-zsh is already installed."
    fi

    echo "Installing powerlevel10k theme..."
    if [[ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    else
        echo "powerlevel10k theme is already installed."
    fi

    echo "Installing zsh plugins: zsh-autosuggestions and zsh-syntax-highlighting..."
    sudo apt-get install -y zsh-autosuggestions zsh-syntax-highlighting

    # Create symbolic links for the zsh plugins in the oh-my-zsh custom plugins directory
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        sudo ln -s /usr/share/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        echo "Created symbolic link for zsh-autosuggestions."
    fi
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        sudo ln -s /usr/share/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        echo "Created symbolic link for zsh-syntax-highlighting."
    fi

else
    echo "Unsupported operating system: $OS"
    exit 1
fi

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
