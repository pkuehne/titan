#!/usr/bin/env bash
# makepkg verifies the download against 1Password's signing key.
set -euo pipefail

"$(dirname "$0")/yay.sh"
curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --import
yay -S --needed 1password
