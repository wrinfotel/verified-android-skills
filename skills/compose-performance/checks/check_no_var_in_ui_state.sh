#!/usr/bin/env bash
# check_no_var_in_ui_state.sh <kotlin-src-dir>
# FLAGS: `var` properties in data classes used as (potential) UI state.
# Rule: SKILL.md §1 — unstable types defeat composable skipping.
# Source: https://developer.android.com/develop/ui/compose/performance/stability
# Heuristic limitation: multiline constructors are handled via grep -z; nested
# parens may cause false negatives. It never produces false positives on files
# without `var` in a data-class parameter list.
set -uo pipefail
target="${1:?usage: check_no_var_in_ui_state.sh <kotlin-src-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=$(grep -rznoE 'data class[^(]*\([^;{)]*\bvar\s+[A-Za-z_]' "$target" --include='*.kt' 2>/dev/null \
  | tr '\0' '\n' | sed 's/^/  /' )
if [ -n "$hits" ]; then
  echo "FAIL check_no_var_in_ui_state: data class with \`var\` property found (unstable UI state):"
  echo "$hits"
  exit 1
fi
echo "PASS check_no_var_in_ui_state"
exit 0
