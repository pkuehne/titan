#!/usr/bin/env bash
# Bootstrap yay from the AUR when it is not installed yet.
set -euo pipefail

command -v yay >/dev/null && exit 0

sudo pacman -S --needed git base-devel
build=$(mktemp -d)
trap 'rm -rf "$build"' EXIT
git clone https://aur.archlinux.org/yay-bin.git "$build"
(cd "$build" && makepkg -si)
