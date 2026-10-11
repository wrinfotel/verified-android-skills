#!/usr/bin/env bash
# check_no_hardcoded_font_size.sh <compose-src-dir>
# FLAGS: fontSize = ... in composable files — text sizes belong to the
#        Typography(...) passed to MaterialTheme; composables style text
#        with MaterialTheme.typography styles.
# Rule: SKILL.md §2.
# Source: https://developer.android.com/develop/ui/compose/designsystems/material3 —
#   "You can retrieve the typography provided to the M3 MaterialTheme
#    composable by using MaterialTheme.typography"; typography is
#   customized via the Typography class given to the theme.
# Heuristic limitations: files whose name contains "theme" or "color"
#   (case-insensitive) are skipped — Typography definitions live there.
set -uo pipefail
target="${1:?usage: check_no_hardcoded_font_size.sh <compose-src-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=""
while IFS= read -r -d '' f; do
  base="${f##*/}"; base="${base,,}"
  case "$base" in *theme*|*color*) continue ;; esac
  grep -q '@Composable' "$f" 2>/dev/null || continue
  m=$(grep -nE '\bfontSize[[:space:]]*=' "$f" 2>/dev/null \
      | grep -vE '(^|:)[0-9]+:[[:space:]]*//' \
      | sed 's/^/    /')
  if [ -n "$m" ]; then
    hits="${hits}  $f: hardcoded fontSize — use MaterialTheme.typography styles:
$m
"
  fi
done < <(find "$target" -type f -name '*.kt' -print0 2>/dev/null)

if [ -n "$hits" ]; then
  echo "FAIL check_no_hardcoded_font_size: hardcoded font size in composables:"
  echo "$hits"
  exit 1
fi
echo "PASS check_no_hardcoded_font_size"
exit 0
