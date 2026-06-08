#!/bin/bash
layout=$(hyprctl -j devices 2>/dev/null | \
    python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    for kb in d.get('keyboards', []):
        if 'translated' in kb.get('name','') or kb.get('main', False):
            print(kb.get('active_keymap','US')[:2].upper())
            break
    else:
        kbs = d.get('keyboards', [])
        if kbs:
            print(kbs[-1].get('active_keymap','US')[:2].upper())
        else:
            print('US')
except:
    print('US')
" 2>/dev/null)

echo "${layout:-US}"
