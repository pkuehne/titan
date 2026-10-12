#!/usr/bin/env bash
set -euo pipefail

"$(dirname "$0")/yay.sh"
yay -S --needed localsend-bin
