#!/usr/bin/env bash
# check_m2_theme_accessor.sh <compose-src-dir>
# FLAGS: MaterialTheme.colors (the Material 2 accessor) in files that import
#        androidx.compose.material3 — compiles when M2 is on the classpath,
#        but reads the M2 theme instead of the app's M3 colorScheme.
# Rule: SKILL.md §3 — mixed M2/M3 API.
# Source: https://developer.android.com/develop/ui/compose/designsystems/material2-material3 —
#   migration mapping: M2 MaterialTheme.colors -> M3 MaterialTheme.colorScheme.
# Heuristic limitations: only fires in files that also import material3
#   (a self-consistent M2-only file is out of scope for an M3 skill).
set -uo pipefail
target="${1:?usage: check_m2_theme_accessor.sh <compose-src-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=""
while IFS= read -r -d '' f; do
  grep -qE '^import[[:space:]]+androidx\.compose\.material3' "$f" 2>/dev/null || continue
  m=$(grep -vE '^[[:space:]]*//' "$f" 2>/dev/null | grep -nE '\bMaterialTheme\.colors\b' 2>/dev/null | sed 's/^/    /')
  if [ -n "$m" ]; then
    hits="${hits}  $f: M2 accessor MaterialTheme.colors in an M3 file — use MaterialTheme.colorScheme:
$m
"
  fi
done < <(find "$target" -type f -name '*.kt' -print0 2>/dev/null)

if [ -n "$hits" ]; then
  echo "FAIL check_m2_theme_accessor: Material 2 theme accessor in an M3 file:"
  echo "$hits"
  exit 1
fi
echo "PASS check_m2_theme_accessor"
exit 0
