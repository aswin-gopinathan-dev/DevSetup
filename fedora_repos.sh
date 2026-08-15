#!/usr/bin/env bash

echo "========================================"
echo " Repository Setup"
echo "========================================"

# ============================================================
# Neovim configuration
# ============================================================

echo
echo ">>> Installing Neovim configuration..."

mkdir -p "$HOME/.config"

if [ ! -d "$HOME/.config/nvim/.git" ]; then
    git clone \
        https://github.com/aswin-gopinathan-dev/nvim.git \
        "$HOME/.config/nvim"
else
    echo "Neovim config already exists."
fi

# ============================================================
# Projects
# ============================================================

echo
echo ">>> Cloning projects..."

mkdir -p "$HOME/Projects"

clone_repo()
{
    local repo="$1"
    local destination="$2"

    if [ ! -d "$destination/.git" ]; then
        git clone "$repo" "$destination"
    else
        echo "$(basename "$destination") already exists."
    fi
}

clone_repo \
    https://github.com/aswin-gopinathan-dev/GPU.git \
    "$HOME/Projects/GPU"

clone_repo \
    https://github.com/aswin-gopinathan-dev/3D.git \
    "$HOME/Projects/3D"

# Uncomment if you ALSO want a development copy of nvim
# under ~/Projects/nvim
#
# clone_repo \
#     https://github.com/aswin-gopinathan-dev/nvim.git \
#     "$HOME/Projects/nvim"

echo
echo "========================================"
echo " Configure Git"
echo "========================================"
git config --global diff.tool kdiff3
git config --global difftool.prompt false
git config --global merge.tool kdiff3
git config --global mergetool.prompt false
git config --global user.name "Aswin Gopinathan"
git config --global user.email "aswin.gopinathan@outlook.com"

echo
echo "========================================"
echo " Repository setup complete"
echo "========================================"
