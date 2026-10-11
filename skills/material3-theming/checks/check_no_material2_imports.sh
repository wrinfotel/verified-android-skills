#!/usr/bin/env bash
# check_no_material2_imports.sh <compose-src-dir>
# FLAGS: androidx.compose.material.* (Material 2) imports in an M3 app —
#        M2 components read the M2 theme, so the app's M3 colorScheme and
#        typography silently do not apply to them.
# Rule: SKILL.md §3.
# Source: https://developer.android.com/develop/ui/compose/designsystems/material2-material3 —
#   M2 -> M3 migration mapping; M3 components consume the M3 theme.
# Heuristic limitations: androidx.compose.material.icons is shared between
#   M2 and M3 and is NOT flagged; an intentionally M2-only app triggers
#   this skill wholesale — it is an M3 skill, opt in on M3 codebases.
set -uo pipefail
target="${1:?usage: check_no_material2_imports.sh <compose-src-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=$(grep -rnE '^import[[:space:]]+androidx\.compose\.material\.' "$target" --include='*.kt' 2>/dev/null \
  | grep -vE 'material\.icons' \
  | grep -vE '(^|:)[0-9]+:[[:space:]]*//' \
  | sed 's/^/  /')
if [ -n "$hits" ]; then
  echo "FAIL check_no_material2_imports: Material 2 import in an M3 app:"
  echo "$hits"
  exit 1
fi
echo "PASS check_no_material2_imports"
exit 0
