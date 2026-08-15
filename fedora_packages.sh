#!/usr/bin/env bash

echo "========================================"
echo " Fedora Package Setup"
echo "========================================"

# ============================================================
# Update Fedora
# ============================================================

echo
echo ">>> Updating Fedora..."

sudo dnf upgrade -y

# ============================================================
# Development packages
# ============================================================

echo
echo ">>> Installing development packages..."

sudo dnf install -y \
    git \
    wget \
    unzip \
    neovim \
    cmake \
    ninja-build \
    gcc-c++ \
    clang \
    lldb \
    gdb \
    python3 \
    python3-pip \
    ripgrep \
    fd-find \
    fzf \
    tmux \
    qt6-qtbase-devel \
    qt6-qtdeclarative-devel \
    mesa-libGL-devel \
    mesa-demos \
    SDL2-devel \
    glm-devel \
    tree-sitter-cli \
    clang-tools-extra \
    rust-analyzer \
    kdiff3

# ============================================================
# Snap
# ============================================================

echo
echo ">>> Installing and enabling Snap..."

sudo dnf install -y snapd
sudo systemctl enable --now snapd.socket

if [ ! -e /snap ]; then
    sudo ln -s /var/lib/snapd/snap /snap
fi

# ============================================================
# Yazi and supporting packages
# ============================================================

echo
echo ">>> Installing Yazi and dependencies..."

sudo dnf install dnf-plugins-core
sudo dnf copr enable lihaohong/yazi
sudo dnf install yazi

sudo dnf install ffmpeg p7zip jq poppler-utils fd-find ripgrep fzf zoxide ImageMagick bat glow

# ============================================================
# JetBrains Mono Nerd Font
# ============================================================

echo
echo ">>> Installing JetBrains Mono Nerd Font..."

FONT_DIR="$HOME/.local/share/fonts"

mkdir -p "$FONT_DIR"

if find "$FONT_DIR" -maxdepth 1 -iname '*JetBrainsMono*NerdFont*.ttf' \
    | grep -q .; then

    echo "JetBrains Mono Nerd Font already installed."
else
    TMP_DIR="$(mktemp -d)"

    wget \
        -O "$TMP_DIR/JetBrainsMono.zip" \
        https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip

    unzip -q \
        "$TMP_DIR/JetBrainsMono.zip" \
        -d "$FONT_DIR"

    rm -rf "$TMP_DIR"

    fc-cache -f
fi

echo
echo "========================================"
echo " Installing Rust"
echo "========================================"
curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh

echo
echo "========================================"
echo " Package setup complete"
echo "========================================"
