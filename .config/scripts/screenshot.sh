#!/usr/bin/env bash
set -eu -o pipefail

DIR="$HOME/screenshots"
mkdir -p "$DIR"

timestamp() {
  date +%Y-%m-%d_%H-%M-%S
}

case "${1:-area}" in

  area)
    hyprshot -m region -o "$DIR" -f "Screenshot_$(timestamp).png"
    ;;

  full)
    hyprshot -m output -o "$DIR" -f "Screenshot_$(timestamp).png"
    ;;

  copy)
    hyprshot -m region --clipboard-only
    ;;

  save)
    hyprshot -m region -o "$DIR" -f "Screenshot_$(timestamp).png"
    ;;

  *)
    notify-send "Screenshot" "Unknown mode" || true
    exit 1
    ;;
esac
