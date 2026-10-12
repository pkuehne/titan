#!/usr/bin/env bash
set -euo pipefail

sudo pacman -S --needed syncthing
systemctl --user enable --now syncthing.service
