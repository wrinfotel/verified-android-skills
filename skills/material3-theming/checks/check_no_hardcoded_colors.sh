#!/usr/bin/env bash
# check_no_hardcoded_colors.sh <compose-src-dir>
# FLAGS: hardcoded colors in composable files — Color(0x...) literals,
#        colorResource(...) lookups, R.color references. Theme colors must
#        come from MaterialTheme.colorScheme roles; palette definitions
#        belong in theme files.
# Rule: SKILL.md §1.
# Source: https://developer.android.com/develop/ui/compose/designsystems/material3 —
#   "You can access Material theme colors in your app via
#    MaterialTheme.colorScheme"; accessible role pairing guidance
#   ("Use on-primary on top of primary ...").
# Heuristic limitations: files whose name contains "theme" or "color"
#   (case-insensitive) are skipped — that is where palette values belong;
#   hardcoded colors inside previews or constants in other files still
#   flag (advisory floor).
set -uo pipefail
target="${1:?usage: check_no_hardcoded_colors.sh <compose-src-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=""
while IFS= read -r -d '' f; do
  base="${f##*/}"; base="${base,,}"
  case "$base" in *theme*|*color*) continue ;; esac
  grep -q '@Composable' "$f" 2>/dev/null || continue
  m=$(grep -nE '\bColor\s*\(\s*0[xX]|\bcolorResource\s*\(|\bR\.color\.' "$f" 2>/dev/null \
      | grep -vE '(^|:)[0-9]+:[[:space:]]*//' \
      | sed 's/^/    /')
  if [ -n "$m" ]; then
    hits="${hits}  $f: hardcoded color — use MaterialTheme.colorScheme roles:
$m
"
  fi
done < <(find "$target" -type f -name '*.kt' -print0 2>/dev/null)

if [ -n "$hits" ]; then
  echo "FAIL check_no_hardcoded_colors: hardcoded colors in composables:"
  echo "$hits"
  exit 1
fi
echo "PASS check_no_hardcoded_colors"
exit 0
