#!/usr/bin/env bash
# Install Steam with the 32-bit graphics drivers for this machine's GPUs.
set -euo pipefail

if ! pacman-conf --repo-list | grep -qx multilib; then
  echo "multilib is not enabled in /etc/pacman.conf" >&2
  exit 1
fi

gpus=$(lspci | grep -iE 'VGA|3D|Display')
packages=()

# Drivers go in before steam: its lib32-vulkan-driver dependency would
# otherwise resolve to whichever provider pacman offers first.
if grep -qi intel <<<"$gpus"; then
  packages+=(lib32-mesa lib32-vulkan-intel)
fi
if grep -qiwE 'AMD|ATI' <<<"$gpus"; then
  packages+=(lib32-mesa lib32-vulkan-radeon)
fi
if grep -qi nvidia <<<"$gpus"; then
  packages+=(lib32-nvidia-utils nvidia-prime)
fi

if ((${#packages[@]})); then
  sudo pacman -S --needed "${packages[@]}"
fi
sudo pacman -S --needed steam
