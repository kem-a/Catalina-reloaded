#!/usr/bin/env bash
#
# Install / uninstall script for the Catalina-reloaded icon theme.
#
# Usage:
#   ./install.sh                 Install for the current user (~/.local/share/icons)
#   ./install.sh -S, --system    Install system-wide (/usr/share/icons, needs root)
#   ./install.sh -r, -u, --uninstall, --remove
#                                Remove the user installation
#   ./install.sh -r -S           Remove the system-wide installation (needs root)
#   ./install.sh -e, --enable    Also enable the theme via gsettings after install
#   ./install.sh --dry-run       Show what would happen, change nothing
#   ./install.sh -h, --help      Show this help

set -euo pipefail

THEME_NAME="Catalina-reloaded"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SYSTEM=0
UNINSTALL=0
DRY_RUN=0
ENABLE=0

usage() {
    sed -n '3,13p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
    exit "${1:-0}"
}

for arg in "$@"; do
    case "$arg" in
        -S|--system)              SYSTEM=1 ;;
        -r|-u|--uninstall|--remove) UNINSTALL=1 ;;
        -e|--enable)              ENABLE=1 ;;
        --dry-run)                DRY_RUN=1 ;;
        -h|--help)                usage 0 ;;
        *) echo "Unknown option: $arg" >&2; usage 1 ;;
    esac
done

# Run a command, or just print it when --dry-run is set.
run() {
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "[dry-run] $*"
    else
        "$@"
    fi
}

if [ "$SYSTEM" -eq 1 ]; then
    DEST_ROOT="/usr/share/icons"
    if [ "$(id -u)" -ne 0 ]; then
        echo "System-wide action requires root. Re-run with sudo." >&2
        exit 1
    fi
else
    DEST_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/icons"
fi

DEST_DIR="$DEST_ROOT/$THEME_NAME"

update_cache() {
    if command -v gtk-update-icon-cache >/dev/null 2>&1; then
        echo "Updating icon cache..."
        run gtk-update-icon-cache -f -t "$1" || true
    fi
}

enable_theme() {
    if ! command -v gsettings >/dev/null 2>&1; then
        echo "gsettings not found; skipping --enable." >&2
        return
    fi
    echo "Enabling $THEME_NAME via gsettings..."
    run gsettings set org.gnome.desktop.interface icon-theme "$THEME_NAME"
}

if [ "$UNINSTALL" -eq 1 ]; then
    if [ -d "$DEST_DIR" ]; then
        echo "Removing $DEST_DIR"
        run rm -rf "$DEST_DIR"
        update_cache "$DEST_ROOT" || true
        [ "$DRY_RUN" -eq 1 ] || echo "Uninstalled $THEME_NAME."
    else
        echo "$THEME_NAME is not installed at $DEST_DIR"
    fi
    exit 0
fi

echo "Installing $THEME_NAME to $DEST_DIR"
run mkdir -p "$DEST_ROOT"
run rm -rf "$DEST_DIR"

# Copy the theme, preserving the scalable@2x / symbolic@2x symlinks.
run cp -a "$SRC_DIR" "$DEST_DIR"

# Drop repo/dev files that don't belong in an installed theme.
run rm -rf "$DEST_DIR/.git" "$DEST_DIR/.github" "$DEST_DIR/.claude" \
       "$DEST_DIR/.vscode" "$DEST_DIR/.gitignore" \
       "$DEST_DIR/install.sh" "$DEST_DIR/README.md" \
       "$DEST_DIR/icon-theme.cache"

update_cache "$DEST_DIR"

if [ "$ENABLE" -eq 1 ]; then
    if [ "$SYSTEM" -eq 1 ]; then
        echo "Note: --enable sets the theme for the current user (root here)." >&2
    fi
    enable_theme
fi

[ "$DRY_RUN" -eq 1 ] && { echo "Dry run complete. Nothing was changed."; exit 0; }

echo "Installed $THEME_NAME."
if [ "$ENABLE" -ne 1 ]; then
    echo "Select it via GNOME Tweaks, LXAppearance, or your desktop's settings."
fi
