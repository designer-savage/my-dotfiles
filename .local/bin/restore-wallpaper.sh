#!/bin/bash
sleep 1
WALL=$(cat ~/.cache/wal/wal 2>/dev/null)
[ -f "$WALL" ] && awww img "$WALL" --transition-type none --transition-duration 0
