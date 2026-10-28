#!/usr/bin/env bash
# Copy the shared references and scripts into every skill that uses them.
# Each skill installs on its own, so each one carries its own copy.
# Edit the files in shared/, never the copies, then run this.
# --check: exit 1 if any copy differs from shared/, without changing anything.
set -eu
cd "$(dirname "$0")/.."

# skill: the shared files it needs
manifest="
taste-brief:      references/handbook.md scripts/contrast.py scripts/screenshot.sh
taste-directions: references/handbook.md scripts/contrast.py scripts/screenshot.sh scripts/roll.py
taste-system:     references/handbook.md scripts/contrast.py
taste-preview:    references/handbook.md scripts/screenshot.sh
taste-judge:      references/handbook.md references/judges.md scripts/contrast.py scripts/screenshot.sh
taste-apply:      references/handbook.md references/judges.md scripts/contrast.py scripts/screenshot.sh
"

check=0
[ "${1:-}" = "--check" ] && check=1
stale=0

while read -r skill files; do
  [ -z "$skill" ] && continue
  skill=${skill%:}
  for f in $files; do
    dest="skills/$skill/$f"
    if [ $check = 1 ]; then
      cmp -s "shared/$f" "$dest" || { echo "out of date: $dest"; stale=1; }
    else
      mkdir -p "$(dirname "$dest")"
      cp -p "shared/$f" "$dest"
    fi
  done
done <<< "$manifest"

if [ $check = 1 ]; then
  [ $stale = 0 ] && echo "all copies match shared/"
  exit $stale
fi
echo "synced shared/ into skills/"
