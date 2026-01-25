#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOSHY_CONFIG="$HOME/.config/toshy/toshy_config.py"
TOSHY_DB="$HOME/.config/toshy/toshy_user_preferences.sqlite"

echo "Applying Mac keyboard settings..."

# Check Toshy is installed
if [ ! -f "$TOSHY_CONFIG" ]; then
    echo "Error: Toshy config not found at $TOSHY_CONFIG"
    echo "Please install Toshy first: ./setup.sh"
    exit 1
fi

# Get GNOME version
GNOME_VER=$(gnome-shell --version 2>/dev/null | grep -oP '\d+' | head -1 || echo "42")
echo "Detected GNOME version: $GNOME_VER"

# Get distro info
DISTRO_ID=$(grep "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"')
DISTRO_VER=$(grep "^VERSION_ID=" /etc/os-release | cut -d= -f2 | tr -d '"')
echo "Detected distro: $DISTRO_ID $DISTRO_VER"

# 1. Configure Toshy preferences
echo "Configuring Toshy preferences..."
sqlite3 "$TOSHY_DB" "
UPDATE config_preferences SET value='Apple' WHERE name='override_kbtype';
INSERT OR REPLACE INTO config_preferences (name, value) VALUES ('override_kbtype', 'Apple');
"
sqlite3 "$TOSHY_DB" "
UPDATE config_preferences SET value='Disabled' WHERE name='optspec_layout';
INSERT OR REPLACE INTO config_preferences (name, value) VALUES ('optspec_layout', 'Disabled');
"

# 2. Patch Toshy config for environment detection
echo "Patching Toshy config..."
python3 "$SCRIPT_DIR/toshy-config-patch.py" "$TOSHY_CONFIG" "$DISTRO_ID" "$DISTRO_VER" "$GNOME_VER"

# 3. Configure GNOME settings
echo "Configuring GNOME settings..."
gsettings set org.gnome.shell.keybindings toggle-overview "['<Control>space']"
gsettings set org.gnome.mutter overlay-key 'Super_L'

# 4. Fix XKB options (remove super:ctrl and win:ctrl)
echo "Fixing XKB options..."
CURRENT_OPTIONS=$(setxkbmap -query | grep options | cut -d: -f2 | xargs)
if [[ "$CURRENT_OPTIONS" == *"super:ctrl"* ]] || [[ "$CURRENT_OPTIONS" == *"win:ctrl"* ]]; then
    echo "Removing conflicting XKB options..."
    setxkbmap -layout us -option ""
    # Re-add caps:escape if it was there
    if [[ "$CURRENT_OPTIONS" == *"caps:escape"* ]]; then
        setxkbmap -option caps:escape
    fi
else
    echo "XKB options OK"
fi

# Ensure caps:escape is set
setxkbmap -option caps:escape 2>/dev/null || true

# Persist XKB settings across reboots
echo "Persisting XKB settings..."
"$SCRIPT_DIR/persist-xkb.sh"

# 5. Restart Toshy services
echo "Restarting Toshy services..."
if command -v toshy-services-restart &>/dev/null; then
    toshy-services-restart
else
    systemctl --user restart toshy-config toshy-session-monitor 2>/dev/null || true
fi

echo "Settings applied successfully!"
