# Catalina-reloaded

An icon theme for Linux inspired by macOS Catalina.

## Sizes

All sizes are also available in HiDPI (`@2x`).

## Installation

### Install script

```bash
# For current user (~/.local/share/icons)
./install.sh

# System-wide (/usr/share/icons)
sudo ./install.sh --system
```

The script copies the theme (preserving the `@2x` symlinks), strips repo/dev
files, and refreshes the icon cache with `gtk-update-icon-cache`.

Options:

| Option | Description |
| --- | --- |
| `-S`, `--system` | Install/remove system-wide (needs root) |
| `-r`, `-u`, `--uninstall`, `--remove` | Remove the installation |
| `-e`, `--enable` | Also enable the theme via `gsettings` after install |
| `--dry-run` | Show what would happen, change nothing |
| `-h`, `--help` | Show help |

To uninstall:

```bash
./install.sh --uninstall            # current user
sudo ./install.sh -r -S             # system-wide
```

### Manual

```bash
# For current user
cp -r Catalina-reloaded ~/.local/share/icons/

# System-wide
sudo cp -r Catalina-reloaded /usr/share/icons/
```

### Apply the theme

Use your desktop environment's settings or a tool like **GNOME Tweaks**, **LXAppearance**, or **kvantum** to select `Catalina-reloaded`.

Or set it from the command line with `gsettings`:

```bash
gsettings set org.gnome.desktop.interface icon-theme 'Catalina-reloaded'
```

To revert to the default:

```bash
gsettings reset org.gnome.desktop.interface icon-theme
```

## Screenshots

_Coming soon._

## Credits

Originally created by **adolfo (zayronxio)** - [github.com/zayronxio/Os-Catalina-icons](https://github.com/zayronxio/Os-Catalina-icons)

Symbolic icons curtesy to **mi7i** author of [Dreams](https://codeberg.org/mi7i/dreams) icon set.

Maintained and extended by **Arnis Kemlers** - [github.com/kem-a](https://github.com/kem-a)

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE).

Copyright (C) adolfo (zayronxio)
Copyright (C) 2026 Arnis Kemlers
