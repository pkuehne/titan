#!/usr/bin/env bash
# Arch's package ships no desktop entry or icon, so add upstream's.
set -euo pipefail

sudo pacman -S --needed syncthing
systemctl --user enable --now syncthing.service

data_dir=${XDG_DATA_HOME:-$HOME/.local/share}
curl -fsSL --create-dirs -o "$data_dir/icons/hicolor/scalable/apps/syncthing.svg" \
  https://raw.githubusercontent.com/syncthing/syncthing/main/assets/logo-only.svg
install -Dm644 /dev/stdin "$data_dir/applications/syncthing-ui.desktop" <<'DESKTOP'
[Desktop Entry]
Name=Syncthing Web UI
GenericName=File synchronization UI
Comment=Opens Syncthing's Web UI in the default browser (Syncthing must already be started).
Exec=syncthing browser
Icon=syncthing
Terminal=false
Type=Application
Keywords=synchronization;interface;
Categories=Network;FileTransfer;P2P
DESKTOP
