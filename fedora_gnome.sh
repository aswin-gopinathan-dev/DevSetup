#!/usr/bin/env bash

echo "========================================"
echo " GNOME Setup"
echo "========================================"

# ============================================================
# GNOME tools
# ============================================================

echo
echo ">>> Installing GNOME tools..."

sudo dnf install -y \
    gnome-tweaks \
    gnome-shell-extension-dash-to-dock \
    gnome-extensions-app \
    flameshot

# ============================================================
# GNOME window configuration
# ============================================================

echo
echo ">>> Configuring GNOME windows..."

# Enable Minimize / Maximize / Close buttons on titlebars.
gsettings set \
    org.gnome.desktop.wm.preferences \
    button-layout \
    'appmenu:minimize,maximize,close'

# ============================================================
# Dash to Dock
# ============================================================

echo
echo ">>> Configuring Dash to Dock..."

DASH_TO_DOCK="dash-to-dock@micxgx.gmail.com"

if gnome-extensions list | grep -q "$DASH_TO_DOCK"; then
    gnome-extensions enable "$DASH_TO_DOCK" || true
else
    echo
    echo "Dash to Dock installed but not visible to this GNOME session yet."
    echo "Log out/in once and run this script again."
fi

if gsettings list-schemas \
    | grep -q '^org.gnome.shell.extensions.dash-to-dock$'; then

    gsettings set \
        org.gnome.shell.extensions.dash-to-dock \
        dock-position \
        'RIGHT'

    gsettings set \
        org.gnome.shell.extensions.dash-to-dock \
        intellihide \
        false

    gsettings set \
        org.gnome.shell.extensions.dash-to-dock \
        dock-fixed \
        true

    gsettings set \
        org.gnome.shell.extensions.dash-to-dock \
        extend-height \
        false

    gsettings set \
        org.gnome.shell.extensions.dash-to-dock \
        height-fraction \
        0.90

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
# Keyboard shortcuts
# ============================================================

echo
echo ">>> Configuring keyboard shortcuts..."

# Disable GNOME's default Print Screen screenshot binding.
SCREENSHOT_SCHEMA="org.gnome.shell.keybindings"

if gsettings list-keys "$SCREENSHOT_SCHEMA" \
    | grep -qx 'show-screenshot-ui'; then

    gsettings set \
        "$SCREENSHOT_SCHEMA" \
        show-screenshot-ui \
        "[]"
fi

CUSTOM_SCHEMA="org.gnome.settings-daemon.plugins.media-keys"
CUSTOM_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

FLAMESHOT_PATH="$CUSTOM_PATH/flameshot/"
TERMINAL_PATH="$CUSTOM_PATH/terminal/"

gsettings set \
    "$CUSTOM_SCHEMA" \
    custom-keybindings \
    "[
        '$FLAMESHOT_PATH',
        '$TERMINAL_PATH'
    ]"

# Print Screen -> Flameshot region selection -> clipboard
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

# Ctrl + Alt + T -> Terminal
gsettings set \
    "$CUSTOM_SCHEMA.custom-keybinding:$TERMINAL_PATH" \
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

echo
echo "========================================"
echo " GNOME setup complete"
echo "========================================"
echo
echo "IMPORTANT:"
echo "If Dash to Dock was installed during this run,"
echo "log out and log back in once, then rerun this script."
