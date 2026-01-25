# Mac-Style Keyboard for Linux (GNOME)

This setup makes a PC keyboard behave like a Mac keyboard on Linux with GNOME:

- **Win+C** = Copy (Cmd+C)
- **Win+V** = Paste (Cmd+V)
- **Win+Space** = Open GNOME Overview (Spotlight equivalent)
- **Win+Tilde** = Switch windows within same app (Cmd+`)
- **Ctrl+C** in terminal = Interrupt (preserved)
- **Caps Lock** = Escape

## Requirements

- Ubuntu/Debian-based Linux with GNOME desktop
- X11 session (not Wayland)

## Quick Setup

```bash
./setup.sh
```

## What It Does

### 1. Installs Toshy

[Toshy](https://github.com/RedBearAK/toshy) is a keyboard remapping tool that provides Mac-like shortcuts on Linux. The setup script clones and runs the Toshy installer.

### 2. Configures Toshy Settings

Sets these preferences in Toshy's SQLite database:

| Setting | Value | Purpose |
|---------|-------|---------|
| `override_kbtype` | `Apple` | Makes Win key act as Cmd |
| `optspec_layout` | `Disabled` | Prevents dead key conflicts with Alt+Grave |

### 3. Patches Toshy Config

Adds environment overrides for proper GNOME detection:
- `OVERRIDE_DISTRO_ID = 'ubuntu'`
- `OVERRIDE_SESSION_TYPE = 'x11'`
- `OVERRIDE_DESKTOP_ENV = 'gnome'`
- `OVERRIDE_DE_MAJ_VER = <your GNOME version>`

Modifies GNOME keymaps to use `Ctrl+Space` for overview toggle.

### 4. Configures GNOME

- Sets `toggle-overview` to `Ctrl+Space`
- Clears conflicting XKB options (`super:ctrl`, `win:ctrl`)
- Keeps `caps:escape` for Caps Lock as Escape

## Manual Setup

If you prefer to set things up manually:

### Install Toshy

```bash
git clone https://github.com/RedBearAK/toshy.git /tmp/toshy
cd /tmp/toshy
./setup_toshy.py
```

### Configure Toshy Preferences

```bash
sqlite3 ~/.config/toshy/toshy_user_preferences.sqlite "
UPDATE config_preferences SET value='Apple' WHERE name='override_kbtype';
UPDATE config_preferences SET value='Disabled' WHERE name='optspec_layout';
"
```

### Configure GNOME

```bash
gsettings set org.gnome.shell.keybindings toggle-overview "['<Control>space']"
gsettings set org.gnome.mutter overlay-key 'Super_L'
```

### Fix XKB Options

```bash
setxkbmap -layout us -option ""
setxkbmap -option caps:escape
```

### Restart Toshy

```bash
toshy-services-restart
```

## Troubleshooting

### Win+Space doesn't work

1. Check if XKB has conflicting options:
   ```bash
   setxkbmap -query
   ```
   If you see `super:ctrl` or `win:ctrl`, clear them:
   ```bash
   setxkbmap -layout us -option ""
   setxkbmap -option caps:escape
   ```

2. Verify GNOME shortcut:
   ```bash
   gsettings get org.gnome.shell.keybindings toggle-overview
   ```
   Should include `'<Control>space'`

### Alt+Tilde produces characters instead of switching windows

Disable the option special layout:
```bash
sqlite3 ~/.config/toshy/toshy_user_preferences.sqlite \
  "UPDATE config_preferences SET value='Disabled' WHERE name='optspec_layout';"
toshy-services-restart
```

### Toshy not detecting GNOME

Edit `~/.config/toshy/toshy_config.py` and set the environment overrides:
```python
OVERRIDE_DESKTOP_ENV = 'gnome'
OVERRIDE_DE_MAJ_VER = 42  # Your GNOME version
```

## Files

- `setup.sh` - Main setup script
- `apply-settings.sh` - Apply settings only (after Toshy is installed)
- `toshy-config-patch.py` - Script to patch Toshy config
