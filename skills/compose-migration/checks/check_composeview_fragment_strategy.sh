#!/usr/bin/env bash
# check_composeview_fragment_strategy.sh <kotlin-src-dir>
# FLAGS: ComposeView used inside a Fragment without an explicit
# setViewCompositionStrategy — the default disposes on window detach and
# may cause state loss during incremental migration; use
# DisposeOnViewTreeLifecycleDestroyed.
# Rule: SKILL.md §1.
# Source: https://developer.android.com/develop/ui/compose/migrate/interoperability-apis/compose-in-views
# Heuristic limitation: file-level — a Fragment and a ComposeView in the
# same file with no strategy token anywhere in it. Binding-property usage
# (binding.composeView) is detected case-insensitively. Full-line //
# comments are ignored.
set -uo pipefail
target="${1:?usage: check_composeview_fragment_strategy.sh <kotlin-src-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=0
while IFS= read -r -d '' f; do
  body=$(grep -vE '^[[:space:]]*//' "$f" 2>/dev/null)
  echo "$body" | grep -qE 'ComposeView|composeView' || continue
  echo "$body" | grep -qE '\bFragment\b' || continue
  echo "$body" | grep -q 'setViewCompositionStrategy' && continue
  echo "FAIL check_composeview_fragment_strategy: ComposeView in Fragment without setViewCompositionStrategy (state loss risk): $f"
  hits=1
done < <(find "$target" -name '*.kt' -type f -print0 2>/dev/null)

[ $hits -ne 0 ] && exit 1
echo "PASS check_composeview_fragment_strategy"
exit 0
