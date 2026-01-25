#!/bin/bash
# Persist XKB settings across reboots
#
# This script creates an autostart entry to apply XKB settings on login.

AUTOSTART_DIR="$HOME/.config/autostart"
AUTOSTART_FILE="$AUTOSTART_DIR/mac-keyboard-xkb.desktop"

mkdir -p "$AUTOSTART_DIR"

cat > "$AUTOSTART_FILE" << 'EOF'
[Desktop Entry]
Type=Application
Name=Mac Keyboard XKB Settings
Comment=Apply XKB settings for Mac-style keyboard
Exec=/bin/bash -c "sleep 2 && setxkbmap -layout us -option '' && setxkbmap -option caps:escape"
Hidden=false
NoDisplay=true
X-GNOME-Autostart-enabled=true
EOF

echo "Created autostart entry: $AUTOSTART_FILE"
echo "XKB settings will be applied on each login."
