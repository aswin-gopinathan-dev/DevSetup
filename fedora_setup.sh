#!/usr/bin/env bash


echo "========================================"
echo " Fedora Development Environment Setup"
echo "========================================"


# ============================================================
# 1. Update Fedora
# ============================================================

echo
echo ">>> Updating Fedora..."

sudo dnf upgrade -y


# ============================================================
# 2. Development packages
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
    clang-tools-extra


echo
echo ">>> Installing and enabling Snap..."

sudo dnf install -y snapd
sudo systemctl enable --now snapd.socket
# Enable classic Snap support
if [ ! -e /snap ]; then
    sudo ln -s /var/lib/snapd/snap /snap
fi

echo
echo ">>> Installing Yazi..."
sudo snap install yazi --classic

sudo dnf install ffmpeg p7zip jq poppler-utils fd-find ripgrep fzf zoxide ImageMagick bat glow

# ============================================================
# 3. GNOME tools
# ============================================================

echo
echo ">>> Installing GNOME tools..."

sudo dnf install -y \
    gnome-tweaks \
    gnome-shell-extension-dash-to-dock \
    gnome-extensions-app \
    flameshot


# ============================================================
# 4. JetBrains Mono Nerd Font
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


# ============================================================
# 5. Neovim configuration
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
# 6. Projects
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


# ============================================================
# 7. GNOME window configuration
# ============================================================

echo
echo ">>> Configuring GNOME windows..."

# Enable:
#
#   Minimize
#   Maximize
#   Close
#
# buttons on titlebars.

gsettings set \
    org.gnome.desktop.wm.preferences \
    button-layout \
    'appmenu:minimize,maximize,close'


# ============================================================
# 8. Dash to Dock
# ============================================================

echo
echo ">>> Configuring Dash to Dock..."

DASH_TO_DOCK="dash-to-dock@micxgx.gmail.com"

# Installing a GNOME Shell extension from a Fedora package does
# not always make it visible to the currently-running Shell
# immediately.
#
# Therefore don't fail the entire setup if enabling it requires
# a logout/login first.

if gnome-extensions list | grep -q "$DASH_TO_DOCK"; then

    gnome-extensions enable "$DASH_TO_DOCK" || true

else

    echo
    echo "Dash to Dock installed but not visible to this GNOME session yet."
    echo "Log out/in once and run this script again."

fi


# Configure Dash to Dock if its schema is available.

if gsettings list-schemas \
    | grep -q '^org.gnome.shell.extensions.dash-to-dock$'; then

    # Right side of screen
    gsettings set \
        org.gnome.shell.extensions.dash-to-dock \
        dock-position \
        'RIGHT'

    # Intelligent autohide OFF
    gsettings set \
        org.gnome.shell.extensions.dash-to-dock \
        intellihide \
        false

    # Always keep dock visible
    gsettings set \
        org.gnome.shell.extensions.dash-to-dock \
        dock-fixed \
        true

    # Do NOT use panel mode
    gsettings set \
        org.gnome.shell.extensions.dash-to-dock \
        extend-height \
        false

    # Approximately your screenshot: 90%
    gsettings set \
        org.gnome.shell.extensions.dash-to-dock \
        height-fraction \
        0.90

    # Icon size from your screenshot
    gsettings set \
        org.gnome.shell.extensions.dash-to-dock \
        dash-max-icon-size \
        32

else

    echo
    echo "Dash-to-Dock settings schema isn't available in"
    echo "the current GNOME session yet."
    echo
    echo "Log out/in once and rerun this script."

fi


# ============================================================
# 9. Keyboard shortcuts
# ============================================================

echo
echo ">>> Configuring keyboard shortcuts..."


# ------------------------------------------------------------
# Disable GNOME's default Print Screen screenshot binding
# ------------------------------------------------------------

# GNOME versions can expose slightly different screenshot
# bindings, so check keys before changing them.

SCREENSHOT_SCHEMA="org.gnome.shell.keybindings"

if gsettings list-keys "$SCREENSHOT_SCHEMA" \
    | grep -qx 'show-screenshot-ui'; then

    gsettings set \
        "$SCREENSHOT_SCHEMA" \
        show-screenshot-ui \
        "[]"
fi


# ============================================================
# Custom shortcut definitions
# ============================================================

CUSTOM_SCHEMA="org.gnome.settings-daemon.plugins.media-keys"
CUSTOM_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

FLAMESHOT_PATH="$CUSTOM_PATH/flameshot/"
TERMINAL_PATH="$CUSTOM_PATH/terminal/"


# Tell GNOME which custom shortcuts exist.

gsettings set \
    "$CUSTOM_SCHEMA" \
    custom-keybindings \
    "[
        '$FLAMESHOT_PATH',
        '$TERMINAL_PATH'
    ]"


# ------------------------------------------------------------
# Print Screen -> Flameshot region selection -> clipboard
# ------------------------------------------------------------

gsettings set \
    "$CUSTOM_SCHEMA.custom-keybinding:$FLAMESHOT_PATH" \
    name \
    'Flameshot Screenshot'

gsettings set \
    "$CUSTOM_SCHEMA.custom-keybinding:$FLAMESHOT_PATH" \
    command \
    'flameshot gui --clipboard'

gsettings set \
    "$CUSTOM_SCHEMA.custom-keybinding:$FLAMESHOT_PATH" \
    binding \
    'Print'


# ------------------------------------------------------------
# Ctrl + Alt + T -> Terminal
# ------------------------------------------------------------

gsettings set \
  org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$TERMINAL_PATH" \
  command \
  'ptyxis'

gsettings set \
    "$CUSTOM_SCHEMA.custom-keybinding:$TERMINAL_PATH" \
    command \
    'gnome-terminal'

gsettings set \
    "$CUSTOM_SCHEMA.custom-keybinding:$TERMINAL_PATH" \
    binding \
    '<Control><Alt>t'


# ============================================================
# Finished
# ============================================================

echo
echo "========================================"
echo " Setup complete"
echo "========================================"
echo
echo "Configured:"
echo "  ✓ Development tools"
echo "  ✓ C / C++ toolchain"
echo "  ✓ Qt 6"
echo "  ✓ OpenGL / Mesa"
echo "  ✓ SDL2"
echo "  ✓ GLM"
echo "  ✓ Neovim"
echo "  ✓ JetBrains Mono Nerd Font"
echo "  ✓ GNOME Tweaks"
echo "  ✓ Dash to Dock"
echo "  ✓ Minimize / Maximize buttons"
echo "  ✓ Print Screen -> Flameshot"
echo "  ✓ Ctrl+Alt+T -> Terminal"
echo
echo "Print Screen:"
echo "    Draw region -> Flameshot -> Clipboard"
echo
echo "Ctrl+Alt+T:"
echo "    Open GNOME Terminal"
echo
echo "IMPORTANT:"
echo "If Dash to Dock was installed during this run,"
echo "log out and log back in once, then rerun this script."
echo
