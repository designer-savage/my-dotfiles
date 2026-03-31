#!/usr/bin/env bash
set -eu -o pipefail

DIR="$HOME/screenshots"
mkdir -p "$DIR"

timestamp() {
  date +%Y-%m-%d_%H-%M-%S
}

notify() {
  command -v notify-send >/dev/null 2>&1 && \
    notify-send "Screenshot" "$1" || true
}

case "${1:-area}" in

  area)
    GEOM=$(slurp) || { notify "Selection cancelled"; exit 0; }
    FILE="$DIR/Screenshot_$(timestamp).png"
    sleep 0.10
    grim -g "$GEOM" - | tee >(wl-copy --type image/png) > "$FILE"
    notify "Saved and copied to clipboard"
    ;;

  full)
    FILE="$DIR/Screenshot_$(timestamp).png"
    sleep 0.10
    grim - | tee >(wl-copy --type image/png) > "$FILE"
    notify "Saved and copied to clipboard"
    ;;

  copy)
    GEOM=$(slurp) || { notify "Selection cancelled"; exit 0; }
    sleep 0.10
    grim -g "$GEOM" - | wl-copy --type image/png
    notify "Copied to clipboard"
    ;;

  save)
    GEOM=$(slurp) || { notify "Selection cancelled"; exit 0; }
    FILE="$DIR/Screenshot_$(timestamp).png"
    sleep 0.10
    grim -g "$GEOM" "$FILE"
    notify "Saved"
    ;;

  *)
    notify "Unknown mode"
    exit 1
    ;;
esac
