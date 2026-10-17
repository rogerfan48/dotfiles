#!/bin/bash
# Set up these dotfiles on macOS (Homebrew) or Linux (no root needed).
#
#   bash ~/.dotfiles/initialization.sh [-y] [--dry-run] [--check-updates]
#     -y, --yes        take the default answer for every question
#     --dry-run        Linux: show the plan and exit
#     --check-updates  compare the pinned Linux versions below with the latest releases
#
# Linux: tools are prebuilt binaries under ~/.local (same versions everywhere,
# no sudo). sudo is only offered for missing system packages (tmux, gcc, ...).
# Without root, zsh comes from zsh-bin and interactive bash hands over to it.
# To upgrade a tool, bump its version here and re-run.

# --- pinned versions (Linux) ----------------------------------------
NVIM_VERSION=0.12.5    # old-glibc builds (neovim-releases) lag; pin a version it has
TS_VERSION=0.27.1      # tree-sitter CLI; nvim-treesitter (main) needs >= 0.26.1
RG_VERSION=15.2.0
FD_VERSION=10.5.0
FZF_VERSION=0.74.5     # >= 0.48 for `fzf --bash` / `fzf --zsh`
BAT_VERSION=0.26.1
LAZYGIT_VERSION=0.66.2
DELTA_VERSION=0.20.1
NODE_VERSION=24.22.0   # LTS
GO_VERSION=1.27.2
ZSH_BIN_COMMIT=0c5d2f31679a6bd9a639c1d0b027feed7c271625 # romkatv/zsh-bin installer (zsh 5.8)

DOTFILES_DIR="$HOME/.dotfiles"
if [[ ! -f "$DOTFILES_DIR/lib/ui.sh" ]]; then
    echo "Clone the repo to $DOTFILES_DIR first (see README)." >&2
    exit 1
fi
source "$DOTFILES_DIR/lib/ui.sh"

ASSUME_YES=0
DRY_RUN=false
CHECK_UPDATES=false
for arg in "$@"; do
    case "$arg" in
        -y | --yes) ASSUME_YES=1 ;;
        --dry-run) DRY_RUN=true ;;
        --check-updates) CHECK_UPDATES=true ;;
        -h | --help) sed -n '2,12p' "$0"; exit 0 ;;
        *) err "Unknown option: $arg (see --help)"; exit 1 ;;
    esac
done
export ASSUME_YES # setup_link.sh asks through the same helper

# --- shared helpers ---------------------------------------------------
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

# Rebuild parsers when Neovim changed (stamp-gated). Reinstalls the full set so
# injection-only parsers (html-in-markdown) survive. A missing stamp means the
# parsers were just built by this Neovim.
rebuild_treesitter_parsers() {
    have nvim || return 0
    local parser_dir="$HOME/.local/share/nvim/site/parser" # nvim-treesitter (main) install dir
    [ -d "$parser_dir" ] || return 0 # not set up yet

    local stamp="$HOME/.local/share/nvim/site/.parsers-built-for" # inside parser/ it reads as a language
    local current
    current="$(nvim --version | head -n 1)"
    if [ ! -f "$stamp" ]; then
        echo "$current" >"$stamp"
        return 0
    fi
    [ "$(cat "$stamp" 2>/dev/null)" == "$current" ] && return 0

    if ! have tree-sitter; then
        warn "tree-sitter CLI missing — skipping parser rebuild"
        return 0
    fi

    if run "Rebuilding treesitter parsers for ${current}" \
        nvim --headless "+lua local ts=require('nvim-treesitter'); local l=ts.get_installed('parsers'); if #l>0 then ts.install(l,{force=true}):wait(600000) end" +qa; then
        echo "$current" >"$stamp"
        ok "Treesitter parsers rebuilt for ${current}"
    else
        warn "Parser rebuild failed — run :TSUpdate inside nvim"
    fi
}

# =======================
# macOS (Homebrew)
# =======================
setup_macos() {
    if ! have brew; then
        err "Homebrew is not installed. Install Homebrew and re-run."
        exit 1
    fi
    step "Setting up environment for macOS"

    step "Updating Homebrew"
    brew update

    step "Installing bash"
    brew install bash

    if [[ -d "/Applications/Ghostty.app" ]]; then
        skip "Ghostty already installed"
    else
        step "Installing Ghostty"
        brew install --cask ghostty
    fi

    # Cmd+Ctrl+drag moves a window from anywhere; Ghostty's hidden titlebar
    # leaves no other drag target. Takes effect after re-login.
    if [[ "$(defaults read -g NSWindowShouldDragOnGesture 2>/dev/null)" == "1" ]]; then
        skip "Drag-anywhere gesture already enabled"
    else
        step "Enabling Cmd+Ctrl drag-anywhere gesture"
        defaults write -g NSWindowShouldDragOnGesture -bool true
        warn "Log out and back in to activate it"
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

    step "Installing tools: nvim bat cppcheck fzf fd node pngpaste lazygit ripgrep tree-sitter git-delta"
    brew install nvim bat cppcheck fzf fd node pngpaste lazygit ripgrep tree-sitter git-delta

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
}

# =======================
# Linux: tools under ~/.local, sudo only for system packages
# =======================
BIN_DIR="$HOME/.local/bin"
OPT_DIR="$HOME/.local/opt"
GH="https://github.com"
export GIT_TERMINAL_PROMPT=0 # never stop at a credential prompt behind a spinner

# ver_ge <a> <b>: version a >= b
ver_ge() {
    [[ -n "$1" && "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n 1)" == "$2" ]]
}

# version_of <cmd>: the first x.y[.z] the command reports
version_of() {
    local flag=--version
    case "$(basename "$1")" in
        tmux) flag=-V ;;
        go) flag=version ;;
    esac
    "$1" $flag 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n 1
}

fetch() { # fetch <url> <file>
    if have curl; then curl -fsSL --retry 2 -o "$2" "$1"; else wget -q -O "$2" "$1"; fi
}

# gh_sha256 <repo> <tag> <asset>: the sha256 GitHub publishes for a release
# asset; empty when unknown (old release, API rate limit, no python3).
gh_sha256() {
    have python3 || return 0
    local json="$TMP_DIR/gh-${1//\//_}-$2.json"
    [[ -s "$json" ]] || fetch "https://api.github.com/repos/$1/releases/tags/$2" "$json" || return 0
    python3 -I - "$json" "$3" <<'EOF' 2>/dev/null
import json, sys
for asset in json.load(open(sys.argv[1])).get("assets", []):
    digest = asset.get("digest") or ""
    if asset["name"] == sys.argv[2] and digest.startswith("sha256:"):
        print(digest[len("sha256:"):])
EOF
}

# download <url> <file> [sha256]: fetch, then verify when a checksum is known
download() {
    fetch "$1" "$2" || { echo "download failed: $1"; return 1; }
    if [[ -z "${3:-}" ]] || ! have sha256sum; then
        echo "not verified (no checksum): ${1##*/}"
        return 0
    fi
    local got
    got="$(sha256sum "$2" | awk '{print $1}')"
    [[ "$got" == "$3" ]] || { echo "sha256 mismatch for ${1##*/}: expected $3, got $got"; return 1; }
    echo "sha256 ok: ${1##*/}"
}

gh_asset() { # gh_asset <repo> <tag> <asset> <file>
    download "$GH/$1/releases/download/$2/$3" "$4" "$(gh_sha256 "$1" "$2" "$3")"
}

# inst_bin <cmd> <repo> <tag> <asset> <binary inside the archive>
inst_bin() {
    local dir="$TMP_DIR/$1"
    mkdir -p "$dir"
    gh_asset "$2" "$3" "$4" "$dir/$4" || return 1
    case "$4" in
        *.tar.gz) tar -xzf "$dir/$4" -C "$dir" "$5" ;;
        *.gz) gunzip -c "$dir/$4" >"$dir/$5" ;;
    esac || return 1
    install -m 755 "$dir/$5" "$BIN_DIR/$1"
}

# inst_tree <name> <archive> <top dir inside it> <cmds...>: unpack a whole
# release (bin/, lib/, share/) to OPT_DIR/<name> and link its bin/<cmd>s
inst_tree() {
    local name="$1" file="$2" top="$3" stage="$OPT_DIR/.$1.new" cmd
    shift 3
    rm -rf "$stage" && mkdir -p "$stage" && tar -xzf "$file" -C "$stage" || return 1
    rm -rf "${OPT_DIR:?}/$name" && mv "$stage/$top" "$OPT_DIR/$name" && rm -rf "$stage" || return 1
    for cmd in "$@"; do ln -sfn "$OPT_DIR/$name/bin/$cmd" "$BIN_DIR/$cmd"; done
}

clone() { [[ -d "$2" ]] || git clone -q --depth 1 "$1" "$2"; }

# retry <cmd...>: one more try after a failure (flaky networks drop git clones)
retry() { "$@" || { echo "retrying: $*"; sleep 3; "$@"; }; }

# Install the lazy.nvim plugins; fails when any enabled plugin is still missing
nvim_plugins() {
    nvim --headless "+Lazy! install" +qa &&
        nvim --headless -c 'lua local n = 0
            for _, p in ipairs(require("lazy").plugins()) do
              if p._.cond ~= false and not p._.installed then n = n + 1; print("missing: " .. p.name) end
            end
            os.exit(n)'
}

inst_nvim() {
    local repo=neovim/neovim asset="nvim-linux-$A_NVIM.tar.gz"
    ver_ge "$GLIBC" 2.34 || repo=neovim/neovim-releases # same release built for glibc 2.17
    gh_asset "$repo" "v$NVIM_VERSION" "$asset" "$TMP_DIR/$asset" &&
        inst_tree nvim "$TMP_DIR/$asset" "nvim-linux-$A_NVIM" nvim
}
inst_tree_sitter() {
    inst_bin tree-sitter tree-sitter/tree-sitter "v$TS_VERSION" "tree-sitter-linux-$A_TS.gz" tree-sitter
}
inst_rg() {
    local a="ripgrep-$RG_VERSION-$ARCH-unknown-linux-musl"
    inst_bin rg BurntSushi/ripgrep "$RG_VERSION" "$a.tar.gz" "$a/rg"
}
inst_fd() {
    local a="fd-v$FD_VERSION-$ARCH-unknown-linux-musl"
    inst_bin fd sharkdp/fd "v$FD_VERSION" "$a.tar.gz" "$a/fd"
}
inst_fzf() {
    inst_bin fzf junegunn/fzf "v$FZF_VERSION" "fzf-$FZF_VERSION-linux_$A_GO.tar.gz" fzf
}
inst_bat() {
    local a="bat-v$BAT_VERSION-$ARCH-unknown-linux-musl"
    inst_bin bat sharkdp/bat "v$BAT_VERSION" "$a.tar.gz" "$a/bat"
}
inst_lazygit() {
    inst_bin lazygit jesseduffield/lazygit "v$LAZYGIT_VERSION" \
        "lazygit_${LAZYGIT_VERSION}_linux_$A_NVIM.tar.gz" lazygit
}
inst_delta() {
    local libc=musl
    [[ "$ARCH" == aarch64 ]] && libc=gnu # no musl build for arm
    local a="delta-$DELTA_VERSION-$ARCH-unknown-linux-$libc"
    inst_bin delta dandavison/delta "$DELTA_VERSION" "$a.tar.gz" "$a/delta"
}
inst_node() {
    local a="node-v$NODE_VERSION-linux-$A_NODE.tar.gz" url="https://nodejs.org/dist/v$NODE_VERSION" sum=""
    fetch "$url/SHASUMS256.txt" "$TMP_DIR/node.sums" && sum="$(awk -v f="$a" '$2 == f {print $1}' "$TMP_DIR/node.sums")"
    download "$url/$a" "$TMP_DIR/$a" "$sum" &&
        inst_tree node "$TMP_DIR/$a" "node-v$NODE_VERSION-linux-$A_NODE" node npm npx corepack &&
        { "$BIN_DIR/corepack" enable pnpm --install-directory "$BIN_DIR" || true; }
}
inst_go() {
    local a="go$GO_VERSION.linux-$A_GO.tar.gz" url="https://dl.google.com/go" sum=""
    fetch "$url/$a.sha256" "$TMP_DIR/go.sum" && sum="$(head -c 64 "$TMP_DIR/go.sum")"
    download "$url/$a" "$TMP_DIR/$a" "$sum" && inst_tree go "$TMP_DIR/$a" go go gofmt || return 1
    # Go tooling kept out of Mason (gopls: LSP+format+imports, golangci-lint: lint)
    GOBIN="$BIN_DIR" "$BIN_DIR/go" install golang.org/x/tools/gopls@latest &&
        "$BIN_DIR/go" clean -cache &&
        fetch https://raw.githubusercontent.com/golangci/golangci-lint/HEAD/install.sh "$TMP_DIR/golangci.sh" &&
        sh "$TMP_DIR/golangci.sh" -b "$BIN_DIR"
}
inst_python_tools() { # uv + pylint (linting.lua prefers ~/.local/bin/pylint)
    fetch https://astral.sh/uv/install.sh "$TMP_DIR/uv.sh" &&
        env UV_INSTALL_DIR="$BIN_DIR" UV_NO_MODIFY_PATH=1 sh "$TMP_DIR/uv.sh" &&
        "$BIN_DIR/uv" tool install pylint
}
inst_zsh_bin() { # static zsh; its installer verifies the archive's sha256
    fetch "https://raw.githubusercontent.com/romkatv/zsh-bin/$ZSH_BIN_COMMIT/install" "$TMP_DIR/zsh-bin.sh" &&
        rm -rf "${OPT_DIR:?}/zsh" &&
        sh "$TMP_DIR/zsh-bin.sh" -d "$OPT_DIR/zsh" -e no -q -a sha256 &&
        ln -sfn "$OPT_DIR/zsh/bin/zsh" "$BIN_DIR/zsh"
}
inst_ohmyzsh() { # git clones instead of the installer: it would rewrite ~/.zshrc
    local custom="$HOME/.oh-my-zsh/custom"
    clone https://github.com/ohmyzsh/ohmyzsh "$HOME/.oh-my-zsh" &&
        clone https://github.com/romkatv/powerlevel10k "$custom/themes/powerlevel10k" &&
        clone https://github.com/zsh-users/zsh-autosuggestions "$custom/plugins/zsh-autosuggestions" &&
        clone https://github.com/zsh-users/zsh-syntax-highlighting "$custom/plugins/zsh-syntax-highlighting"
}
inst_tpm() { clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"; }
inst_fonts() {
    have fc-cache || echo "fontconfig missing: fonts are copied but not registered"
    install_jetbrainsmono_font && install_jf_openhuninn_font
}
inst_system() { # credentials were cached by `sudo -v` in the foreground
    if [[ "$PKG_MGR" == apt-get ]]; then
        $SUDO_CMD apt-get update && $SUDO_CMD env DEBIAN_FRONTEND=noninteractive apt-get install -y "${SYS_PKGS[@]}"
    else
        $SUDO_CMD "$PKG_MGR" install -y "${SYS_PKGS[@]}"
    fi
}

# --- environment ------------------------------------------------------
detect_linux() {
    case "$(uname -m)" in
        x86_64 | amd64) ARCH=x86_64 A_NVIM=x86_64 A_GO=amd64 A_NODE=x64 A_TS=x64 ;;
        aarch64 | arm64) ARCH=aarch64 A_NVIM=arm64 A_GO=arm64 A_NODE=arm64 A_TS=arm64 ;;
        *) err "Unsupported CPU $(uname -m): x86_64 and aarch64 only"; exit 1 ;;
    esac
    GLIBC="$(getconf GNU_LIBC_VERSION 2>/dev/null | awk '{print $2}')" # empty on musl
    DISTRO="$( (. /etc/os-release && echo "$PRETTY_NAME") 2>/dev/null || echo Linux)"
    PKG_MGR=""
    for m in apt-get dnf yum; do have "$m" && { PKG_MGR=$m; break; }; done
    if [[ $EUID -eq 0 ]]; then
        SUDO=root SUDO_CMD=""
    elif sudo -n true 2>/dev/null; then
        SUDO=yes SUDO_CMD="sudo -n"
    elif have sudo && id -nG | grep -qwE 'sudo|wheel|admin'; then
        SUDO=password SUDO_CMD="sudo -n"
    else
        SUDO=no SUDO_CMD=""
    fi
}

# Directories this script fills, for the before/after disk usage
MANAGED_DIRS=("$OPT_DIR" "$BIN_DIR" "$HOME/.local/share/nvim" "$HOME/.oh-my-zsh" "$HOME/.tmux"
    "$HOME/.local/share/fonts" "$HOME/.local/share/uv" "$HOME/go")
managed_kb() { du -sk "${MANAGED_DIRS[@]}" 2>/dev/null | awk '{s += $1} END {print s + 0}'; }

quota_line() { # "2.9G used of 4.0G" when a user quota applies
    have quota || return 0
    quota -s -w 2>/dev/null | awk 'NR > 2 && NF >= 4 && $4 != "0" {print $2 " used of " $4 " quota"; exit}'
}

show_environment() {
    section "Environment"
    printf '  %-8s %s · %s · glibc %s\n' system "$DISTRO" "$ARCH" "${GLIBC:-none (musl?)}"
    case "$SUDO" in
        root) printf '  %-8s %s\n' sudo "running as root" ;;
        yes) printf '  %-8s %s\n' sudo "available" ;;
        password) printf '  %-8s %s\n' sudo "may work (asks your password)" ;;
        no) printf '  %-8s %s\n' sudo "no: missing system packages are only reported" ;;
    esac
    local q
    q="$(quota_line)"
    printf '  %-8s %s free%s\n' disk "$(df -Ph "$HOME" | awk 'NR == 2 {print $4}')" "${q:+ · $q}"
}

# --- plan -------------------------------------------------------------
P_NAME=() P_NOW=() P_TARGET=() P_ACT=() P_NOTE=() P_FN=()
add_row() { # add_row <name> <now> <target> <install|upgrade|ok|system|skip|na> <note> <installer>
    P_NAME+=("$1") P_NOW+=("${2:--}") P_TARGET+=("$3") P_ACT+=("$4") P_NOTE+=("$5") P_FN+=("$6")
}

# plan_tool <cmd> <pinned> <min system version or ""> <size> <installer> [glibc needed]
# Anything in BIN_DIR counts as ours (upgraded to the pin); another copy on
# PATH is kept when it is new enough.
plan_tool() {
    local cmd="$1" pin="$2" min="$3" size="$4" fn="$5" glibc="${6:-}" now="" act=install
    if [[ -e "$BIN_DIR/$cmd" ]]; then
        now="$(version_of "$BIN_DIR/$cmd")"
        act=upgrade
        [[ "$now" == "$pin" || "$pin" == latest ]] && act=ok
    elif have "$cmd"; then
        now="$(version_of "$cmd")"
        if [[ -z "$min" ]] || ver_ge "$now" "$min"; then act=system; fi
    fi
    if [[ "$act" == install || "$act" == upgrade ]] && [[ -n "$glibc" ]] && ! ver_ge "$GLIBC" "$glibc"; then
        act=na size="needs glibc $glibc (have ${GLIBC:-none})"
    fi
    add_row "$cmd" "$now" "$pin" "$act" "$size" "$fn"
}

# want <cmd> <min version or ""> <question> <default y|n>: true when the
# optional tool is already usable or the user picks it
want() {
    if [[ -e "$BIN_DIR/$1" ]] || { have "$1" && { [[ -z "$2" ]] || ver_ge "$(version_of "$1")" "$2"; }; }; then
        return 0
    fi
    ask "$3" "$4"
}

plan_linux() {
    want node 20 "Node.js $NODE_VERSION: Copilot and npm-based language servers (~190 MB)?" y &&
        WANT_NODE=true || WANT_NODE=false
    want go "" "Go $GO_VERSION + gopls + golangci-lint (~700 MB)?" n && WANT_GO=true || WANT_GO=false
    want uv "" "uv + pylint for Python linting (~80 MB)?" n && WANT_UV=true || WANT_UV=false

    local omz=ok d
    for d in "" /custom/themes/powerlevel10k /custom/plugins/zsh-autosuggestions /custom/plugins/zsh-syntax-highlighting; do
        [[ -d "$HOME/.oh-my-zsh$d" ]] || omz=install
    done
    WANT_ZSH=true
    if [[ "$omz" == install ]]; then
        if have zsh || [[ -x "$BIN_DIR/zsh" ]]; then
            ask "oh-my-zsh + powerlevel10k for zsh?" y || WANT_ZSH=false
        else
            ask "zsh + oh-my-zsh + powerlevel10k (~45 MB)?" y || WANT_ZSH=false
        fi
    fi

    WANT_FONTS=false
    if ! ls "$HOME/.local/share/fonts"/*JetBrainsMono*.ttf >/dev/null 2>&1; then
        ask "Fonts (JetBrainsMono, jf-openhuninn; only useful on a desktop)?" n && WANT_FONTS=true
    fi

    # System packages: installable only with sudo and a known package manager
    local -A pkg
    local m
    if [[ "$PKG_MGR" == apt-get ]]; then
        pkg=([tmux]=tmux [cc]=build-essential [make]=build-essential [unzip]=unzip [python3-venv]=python3-venv [zsh]=zsh)
    else
        pkg=([tmux]=tmux [cc]=gcc [make]=make [unzip]=unzip [python3-venv]=python3 [zsh]=zsh)
    fi
    MISSING=()
    have tmux || MISSING+=(tmux)
    have cc || have gcc || MISSING+=(cc)
    have make || MISSING+=(make)
    have unzip || MISSING+=(unzip)
    # Mason's Python tools (clang-format, black, ...) need a venv-capable python >= 3.8
    python3 -c 'import sys, ensurepip, venv; sys.exit(sys.version_info < (3, 8))' 2>/dev/null ||
        MISSING+=(python3-venv)
    SYS_PKGS=()
    USE_SUDO=false
    if [[ "$SUDO" != no && -n "$PKG_MGR" ]]; then
        local names=() wanted=("${MISSING[@]}")
        # with sudo, zsh comes from the system (so chsh works); otherwise zsh-bin
        [[ "$WANT_ZSH" == true ]] && ! have zsh && ! [[ -x "$BIN_DIR/zsh" ]] && wanted+=(zsh)
        for m in "${wanted[@]}"; do
            [[ " ${names[*]} " == *" ${pkg[$m]} "* ]] || names+=("${pkg[$m]}")
        done
        if ((${#names[@]})) && ask "Install missing system packages with ${SUDO_CMD:+sudo }$PKG_MGR: ${names[*]}?" y; then
            USE_SUDO=true SYS_PKGS=("${names[@]}")
        fi
    fi

    if [[ "$USE_SUDO" == true ]]; then
        add_row "system pkgs" "" "" install "${SYS_PKGS[*]}" inst_system
    elif ((${#MISSING[@]})); then
        add_row "system pkgs" "" "" na "missing ${MISSING[*]} (ask the admin)" ""
    fi
    local -A why=([tmux]="no tmux" [cc]="no treesitter parsers or telescope-fzf-native"
        [make]="no telescope-fzf-native" [unzip]="Mason can't unpack most language servers"
        [python3-venv]="no Python-based Mason tools (clang-format, black, ...)")
    MISSING_WHY=()
    if [[ "$USE_SUDO" != true ]]; then
        for m in "${MISSING[@]}"; do MISSING_WHY+=("$m: ${why[$m]}"); done
    fi
    plan_tool nvim "$NVIM_VERSION" 0.12 "40 MB" inst_nvim 2.17
    plan_tool tree-sitter "$TS_VERSION" 0.26.1 "28 MB" inst_tree_sitter 2.39
    plan_tool rg "$RG_VERSION" "" "5 MB" inst_rg
    plan_tool fd "$FD_VERSION" "" "4 MB" inst_fd
    plan_tool fzf "$FZF_VERSION" 0.48 "5 MB" inst_fzf
    plan_tool bat "$BAT_VERSION" "" "6 MB" inst_bat
    plan_tool lazygit "$LAZYGIT_VERSION" 0.64 "19 MB" inst_lazygit # config.yml: git.diffRenderers
    plan_tool delta "$DELTA_VERSION" "" "7 MB" inst_delta
    if [[ "$WANT_NODE" == true ]]; then
        plan_tool node "$NODE_VERSION" 20 "190 MB" inst_node 2.28
    else
        add_row node "" "$NODE_VERSION" skip "Copilot and npm-based tools stay off" ""
    fi
    [[ "$WANT_GO" == true ]] && plan_tool go "$GO_VERSION" "" "700 MB" inst_go
    [[ "$WANT_UV" == true ]] && plan_tool uv latest "" "80 MB" inst_python_tools
    if [[ "$WANT_ZSH" == true ]]; then
        if [[ -e "$BIN_DIR/zsh" ]]; then
            add_row zsh "$(version_of "$BIN_DIR/zsh")" 5.8 ok "zsh-bin" ""
        elif have zsh; then
            add_row zsh "$(version_of zsh)" "" system "" ""
        elif [[ " ${SYS_PKGS[*]} " == *" zsh "* ]]; then
            add_row zsh "" "" install "with the system packages" ""
        else
            add_row zsh "" 5.8 install "zsh-bin, 35 MB" inst_zsh_bin
        fi
        add_row oh-my-zsh "" "" "$omz" "+ powerlevel10k, 2 plugins" inst_ohmyzsh
    fi
    if have tmux || [[ " ${SYS_PKGS[*]} " == *" tmux "* ]]; then
        if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
            add_row tpm "" "" ok "" ""
        else
            add_row tpm "" "" install "tmux plugin manager" inst_tpm
        fi
    fi
    if [[ "$WANT_FONTS" == true ]]; then add_row fonts "" "" install "~/.local/share/fonts" inst_fonts; fi
}

print_plan() {
    section "Plan"
    printf '  %s%-12s %-9s %-9s %s%s\n' "$C_DIM" "" now target action "$C_RESET"
    local i act note
    for i in "${!P_NAME[@]}"; do
        case "${P_ACT[i]}" in
            install) act="${C_BLUE}install${C_RESET}" ;;
            upgrade) act="${C_YELLOW}upgrade${C_RESET}" ;;
            ok) act="${C_GREEN}✓ up to date${C_RESET}" ;;
            system) act="${C_DIM}system copy${C_RESET}" ;;
            skip) act="${C_DIM}skip${C_RESET}" ;;
            na) act="${C_RED}unavailable${C_RESET}" ;;
        esac
        note="${P_NOTE[i]}"
        [[ "${P_ACT[i]}" == ok || "${P_ACT[i]}" == system ]] && note=""
        printf '  %-12s %-9s %-9s %s %s%s%s\n' "${P_NAME[i]}" "${P_NOW[i]}" "${P_TARGET[i]}" \
            "$act" "$C_DIM" "$note" "$C_RESET"
    done
    printf '  %s+ links (setup_link.sh), ~/.bashrc block, tmux and Neovim plugins%s\n' "$C_DIM" "$C_RESET"
}

# --- shell ------------------------------------------------------------
# Login shell: chsh when zsh is a registered system shell, otherwise let
# interactive bash exec zsh. Sets ZSH_EXEC (path for the bashrc hook, or empty).
choose_login_shell() {
    ZSH_EXEC=""
    [[ "$WANT_ZSH" == true ]] || return 0
    local zsh_path login
    zsh_path="$(command -v zsh)"
    login="$(getent passwd "$USER" 2>/dev/null | cut -d: -f7)"
    [[ "$(basename "${login:-}")" == zsh ]] && return 0
    if [[ "$zsh_path" != "$BIN_DIR/zsh" ]] && grep -qxF "$zsh_path" /etc/shells 2>/dev/null &&
        [[ "$ASSUME_YES" != 1 ]] && ask "Make zsh your login shell (chsh asks your password)?" y &&
        chsh -s "$zsh_path"; then
        ok "Login shell set to $zsh_path (log in again to apply)"
        return 0
    fi
    if [[ "$zsh_path" == "$BIN_DIR/zsh" ]]; then
        ZSH_EXEC='$HOME/.local/bin/zsh'
    else
        ZSH_EXEC="$zsh_path"
    fi
}

# Managed block at the end of ~/.bashrc, rewritten on every run.
write_bashrc_block() {
    local rc="$HOME/.bashrc" begin="# >>> dotfiles >>>" end="# <<< dotfiles <<<"
    touch "$rc"
    sed -i "/^$begin\$/,/^$end\$/d" "$rc"
    # the block must start on its own line even if the file lacks a final newline
    [[ -s "$rc" && -n "$(tail -c 1 "$rc")" ]] && echo >>"$rc"
    {
        echo "$begin"
        cat <<'EOF'
# Written by ~/.dotfiles/initialization.sh; edits inside are overwritten.
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) PATH="$HOME/.local/bin:$PATH" ;; esac
export VISUAL=nvim EDITOR=nvim
alias nvimleet='LEETCODE_SESSION=1 nvim -c "Leet"'
command -v fzf >/dev/null && eval "$(fzf --bash)"
EOF
        if [[ -n "$ZSH_EXEC" ]]; then
            cat <<EOF
# No chsh here, so interactive bash hands over to zsh. Kept: bash -c, scp,
# bash started from zsh, and NO_ZSH=1 bash.
if [[ \$- == *i* && -z \${BASH_EXECUTION_STRING:-} && -z \${NO_ZSH:-} && -x "$ZSH_EXEC" &&
    "\$(ps -o comm= -p \$PPID 2>/dev/null)" != zsh ]]; then
    export SHELL="$ZSH_EXEC"
    exec "\$SHELL" -l
fi
EOF
        fi
        echo "$end"
    } >>"$rc"
}

# --- run --------------------------------------------------------------
setup_linux() {
    detect_linux
    show_environment

    echo
    plan_linux
    print_plan
    [[ "$DRY_RUN" == true ]] && { skip "Dry run: nothing changed"; exit 0; }
    echo
    ask "Proceed?" y || { err "Installation aborted."; exit 1; }

    mkdir -p "$BIN_DIR" "$OPT_DIR" "$(dirname "$LOG")"
    : >"$LOG"
    export PATH="$BIN_DIR:$PATH"
    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT
    local before i n=0 total=0 label done_count=0 fail=()
    before="$(managed_kb)"

    for i in "${!P_ACT[@]}"; do
        [[ "${P_ACT[i]}" == install || "${P_ACT[i]}" == upgrade ]] && [[ -n "${P_FN[i]}" ]] && ((total++))
    done
    if [[ "$USE_SUDO" == true && -n "$SUDO_CMD" ]] && ! sudo -v; then
        warn "sudo failed; skipping system packages"
        P_ACT[0]=na # the system pkgs row is always first
        ((total--))
    fi
    if ((total > 0)); then
        section "Installing ($total steps, log: ${LOG/#$HOME/\~})"
    else
        section "Tools"
        ok "Everything is up to date"
    fi
    for i in "${!P_ACT[@]}"; do
        [[ "${P_ACT[i]}" == install || "${P_ACT[i]}" == upgrade ]] && [[ -n "${P_FN[i]}" ]] || continue
        ((n++))
        label="[$n/$total] ${P_NAME[i]}${P_TARGET[i]:+ ${P_TARGET[i]}}"
        if run "$label" "${P_FN[i]}"; then
            ok "$label"
            ((done_count++))
        else
            fail+=("${P_NAME[i]}")
        fi
    done

    section "Links"
    bash "$DOTFILES_DIR/setup_link.sh"

    section "Shell and plugins"
    if have tmux && [[ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" && -e "$HOME/.tmux.conf" ]]; then
        if run "tmux plugins" retry "$HOME/.tmux/plugins/tpm/bin/install_plugins"; then
            ok "tmux plugins"
        else
            fail+=("tmux plugins")
        fi
    fi
    choose_login_shell
    write_bashrc_block
    ok "~/.bashrc block${ZSH_EXEC:+ (interactive bash starts zsh)}"
    if have nvim; then
        # Plugins only; language tools install when a file type is first opened
        if run "Neovim plugins" retry nvim_plugins; then
            ok "Neovim plugins"
        else
            fail+=("Neovim plugins")
        fi
        rebuild_treesitter_parsers
    fi

    section "Summary"
    local after
    after="$(managed_kb)"
    printf '  %s✓ %d installed or upgraded%s' "$C_GREEN" "$done_count" "$C_RESET"
    ((${#fail[@]})) && printf '   %s✗ failed: %s%s' "$C_RED" "${fail[*]}" "$C_RESET"
    printf '\n  disk: %+d MB in ~/.local and friends%s\n' $(((after - before) / 1024)) \
        "$(q="$(quota_line)"; [[ -n "$q" ]] && echo " · $q")"
    for i in "${!P_ACT[@]}"; do
        [[ "${P_ACT[i]}" == na && "${P_NAME[i]}" != "system pkgs" ]] && warn "${P_NAME[i]}: ${P_NOTE[i]}"
    done
    for i in "${MISSING_WHY[@]}"; do warn "missing $i (ask the admin)"; done
    if have nvim && ! have tree-sitter; then
        warn "Without the tree-sitter CLI only Neovim's bundled parsers (c, lua, markdown, vim, ...) highlight"
    fi
    ok "Done. Open a new shell (or: exec bash -l), then nvim: language tools install on first use."
}

# --check-updates: pinned Linux versions vs. the latest releases
check_updates() {
    get() { if have curl; then curl -fsSL "$1"; else wget -qO- "$1"; fi; }
    report() {
        local mark="${C_GREEN}✓${C_RESET}"
        [[ -z "$3" ]] && mark="${C_DIM}? lookup failed${C_RESET}"
        [[ -n "$3" && "$2" != "$3" ]] && mark="${C_YELLOW}newer release${C_RESET}"
        printf '  %-12s %-9s %-9s %s\n' "$1" "$2" "${3:--}" "$mark"
    }
    section "Pinned versions vs. latest releases"
    printf '  %s%-12s %-9s %-9s%s\n' "$C_DIM" "" pinned latest "$C_RESET"
    local row name repo pin
    for row in "nvim neovim/neovim $NVIM_VERSION" "tree-sitter tree-sitter/tree-sitter $TS_VERSION" \
        "rg BurntSushi/ripgrep $RG_VERSION" "fd sharkdp/fd $FD_VERSION" "fzf junegunn/fzf $FZF_VERSION" \
        "bat sharkdp/bat $BAT_VERSION" "lazygit jesseduffield/lazygit $LAZYGIT_VERSION" \
        "delta dandavison/delta $DELTA_VERSION"; do
        read -r name repo pin <<<"$row"
        report "$name" "$pin" "$(get "https://api.github.com/repos/$repo/releases/latest" |
            sed -nE 's/.*"tag_name": *"v?([^"]+)".*/\1/p' | head -n 1)"
    done
    report node "$NODE_VERSION" "$(get https://nodejs.org/dist/index.json | python3 -c \
        'import json, sys; print(next(r["version"][1:] for r in json.load(sys.stdin) if r["lts"]))' 2>/dev/null)"
    report go "$GO_VERSION" "$(get 'https://go.dev/VERSION?m=text' | head -n 1 | sed 's/^go//')"
    skip "Bump a version at the top of initialization.sh and re-run to upgrade (macOS: brew upgrade)"
}

# =======================
# Main
# =======================
OS=$(uname -s)
if [[ "$CHECK_UPDATES" == true ]]; then
    check_updates
    exit 0
fi
if ! have git; then
    err "git is not installed. Install git (Homebrew on macOS, apt on Linux) and re-run."
    exit 1
fi

if [[ "$OS" == "Darwin" ]]; then
    ask "This script will install tools with Homebrew and link the dotfiles. Continue?" y ||
        { err "Installation aborted."; exit 1; }
    step "Setting up environment for macOS"
    setup_macos
    set_zsh_default
    rebuild_treesitter_parsers
    step "Creating dotfiles symbolic links"
    bash "$DOTFILES_DIR/setup_link.sh"
    ok "Environment initialization complete!"
elif [[ "$OS" == "Linux" ]]; then
    for c in tar gunzip install sort; do
        have "$c" || { err "$c is not installed; ask the admin for it."; exit 1; }
    done
    have curl || have wget || { err "Neither curl nor wget is installed."; exit 1; }
    LOG="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/install.log"
    printf '%sdotfiles%s · Linux setup, everything under ~/.local\n' "$C_BOLD" "$C_RESET"
    setup_linux
else
    err "Unsupported operating system: $OS"
    exit 1
fi
