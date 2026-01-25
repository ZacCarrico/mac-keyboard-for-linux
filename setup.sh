#!/bin/bash
set -e

echo "=== Mac-Style Keyboard Setup for Linux (GNOME) ==="
echo

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check for GNOME
if [ "$XDG_CURRENT_DESKTOP" != "ubuntu:GNOME" ] && [ "$XDG_CURRENT_DESKTOP" != "GNOME" ]; then
    echo "Warning: This script is designed for GNOME desktop."
    echo "Current desktop: $XDG_CURRENT_DESKTOP"
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check for X11
if [ "$XDG_SESSION_TYPE" != "x11" ]; then
    echo "Warning: This script is designed for X11 sessions."
    echo "Current session type: $XDG_SESSION_TYPE"
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if Toshy is installed
if [ ! -d "$HOME/.config/toshy" ]; then
    echo "Toshy is not installed. Installing now..."
    echo

    # Clone Toshy
    TOSHY_TMP="/tmp/toshy-install-$$"
    git clone https://github.com/RedBearAK/toshy.git "$TOSHY_TMP"
    cd "$TOSHY_TMP"

    echo
    echo "Running Toshy installer..."
    echo "Please follow the prompts."
    echo
    ./setup_toshy.py

    cd -
    rm -rf "$TOSHY_TMP"

    echo
    echo "Toshy installed. Waiting for services to start..."
    sleep 5
else
    echo "Toshy is already installed."
fi

# Apply settings
echo
echo "Applying keyboard settings..."
"$SCRIPT_DIR/apply-settings.sh"

echo
echo "=== Setup Complete ==="
echo
echo "Your keyboard is now configured for Mac-style shortcuts:"
echo "  Win+C/V/X/Z  = Copy/Paste/Cut/Undo"
echo "  Win+Space    = GNOME Overview (Spotlight)"
echo "  Win+Tilde    = Switch windows in same app"
echo "  Ctrl+C       = Interrupt (in terminal)"
echo "  Caps Lock    = Escape"
echo
echo "You may need to log out and back in for all changes to take effect."
