#!/usr/bin/env python3
"""
Patch Toshy config for Mac-style keyboard on GNOME.

This script:
1. Sets environment overrides for GNOME detection
2. Modifies GNOME keymaps to use Ctrl+Space for overview
"""

import sys
import re
import shutil
from pathlib import Path
from datetime import datetime


def backup_file(filepath: Path) -> Path:
    """Create a timestamped backup of the file."""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = filepath.with_suffix(f".py.backup_{timestamp}")
    shutil.copy2(filepath, backup_path)
    return backup_path


def patch_env_overrides(content: str, distro_id: str, distro_ver: str, gnome_ver: str) -> str:
    """Patch the environment override section."""

    # Pattern to match the env_overrides section
    pattern = r"(###  SLICE_MARK_START: env_overrides.*?# MANUALLY set any environment information if the auto-identification isn't working:\n)OVERRIDE_DISTRO_ID\s*=\s*.*?\nOVERRIDE_DISTRO_VER\s*=\s*.*?\nOVERRIDE_VARIANT_ID\s*=\s*.*?\nOVERRIDE_SESSION_TYPE\s*=\s*.*?\nOVERRIDE_DESKTOP_ENV\s*=\s*.*?\nOVERRIDE_DE_MAJ_VER\s*=\s*.*?\n"

    replacement = rf"""\1OVERRIDE_DISTRO_ID       = '{distro_id}'
OVERRIDE_DISTRO_VER      = '{distro_ver}'
OVERRIDE_VARIANT_ID      = None
OVERRIDE_SESSION_TYPE    = 'x11'
OVERRIDE_DESKTOP_ENV     = 'gnome'
OVERRIDE_DE_MAJ_VER      = {gnome_ver}
"""

    new_content, count = re.subn(pattern, replacement, content, flags=re.DOTALL)
    if count == 0:
        print("Warning: Could not find env_overrides section to patch")
    else:
        print(f"Patched environment overrides (GNOME {gnome_ver})")

    return new_content


def patch_gnome_keymaps(content: str) -> str:
    """Patch GNOME keymaps to use Ctrl+Space for overview."""

    # Pattern for pre-GNOME 45 keymap
    pattern1 = r'(if DESKTOP_ENV == \'gnome\':\s+if is_pre_GNOME_45\(DE_MAJ_VER\):.*?keymap\("GenGUI overrides: pre-GNOME 45 fix", \{\s+)C\("RC-Space"\):\s*\[.*?\],'
    replacement1 = r'\1C("RC-Space"):             [iEF2NT(), C("C-Space")],'

    new_content, count1 = re.subn(pattern1, replacement1, content, flags=re.DOTALL)

    # Pattern for main GNOME keymap
    pattern2 = r'(keymap\("GenGUI overrides: GNOME", \{\s+)C\("RC-Space"\):\s*\[.*?\],'
    replacement2 = r'\1C("RC-Space"):             [iEF2NT(), C("C-Space")],'

    new_content, count2 = re.subn(pattern2, replacement2, new_content, flags=re.DOTALL)

    if count1 > 0 or count2 > 0:
        print(f"Patched GNOME keymaps ({count1 + count2} replacements)")
    else:
        print("Warning: Could not find GNOME keymaps to patch (may already be patched)")

    return new_content


def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <toshy_config.py> [distro_id] [distro_ver] [gnome_ver]")
        sys.exit(1)

    config_path = Path(sys.argv[1])
    distro_id = sys.argv[2] if len(sys.argv) > 2 else "ubuntu"
    distro_ver = sys.argv[3] if len(sys.argv) > 3 else "22.04"
    gnome_ver = sys.argv[4] if len(sys.argv) > 4 else "42"

    if not config_path.exists():
        print(f"Error: Config file not found: {config_path}")
        sys.exit(1)

    # Create backup
    backup_path = backup_file(config_path)
    print(f"Created backup: {backup_path}")

    # Read content
    content = config_path.read_text()

    # Apply patches
    content = patch_env_overrides(content, distro_id, distro_ver, gnome_ver)
    content = patch_gnome_keymaps(content)

    # Write patched content
    config_path.write_text(content)
    print(f"Patched config saved: {config_path}")


if __name__ == "__main__":
    main()
