#!/bin/bash
read -r total used <<< "$(free -b | awk '/^Mem:/{print $2, $3}')"
pct=$((used * 100 / total))
used_gb=$(awk "BEGIN {printf \"%.1f\", $used / 1073741824}")
total_gb=$(awk "BEGIN {printf \"%.1f\", $total / 1073741824}")

css_class=""
[ "$pct" -gt 80 ] && css_class="warning"

printf '{"text":"󰍛 %d%%","tooltip":"%sGB / %sGB","class":"%s"}\n' \
    "$pct" "$used_gb" "$total_gb" "$css_class"
