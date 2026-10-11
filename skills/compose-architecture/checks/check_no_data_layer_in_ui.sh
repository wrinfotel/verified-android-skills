#!/usr/bin/env bash
# check_no_data_layer_in_ui.sh <kotlin-src-dir>
# FLAGS: data-layer references (Room, Retrofit, DataStore, *Repository,
# *Dao) imported into files that declare composables.
# Rule: SKILL.md §1 — dependencies point downward only; the UI reads state
# from a state holder, never from the data layer.
# Source: https://developer.android.com/topic/architecture
#         https://developer.android.com/topic/architecture/ui-layer/stateholders
# Heuristic limitation: import-based (fully-qualified inline usage without
# an import is not seen). Never flags files without @Composable declarations.
set -uo pipefail
target="${1:?usage: check_no_data_layer_in_ui.sh <kotlin-src-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=0
while IFS= read -r -d '' f; do
  bad=$(grep -nE '^import (androidx\.room\.|retrofit2\.|androidx\.datastore\.|.*\bRepository$|.*\bDao$)' "$f" 2>/dev/null)
  if [ -n "$bad" ]; then
    [ $hits -eq 0 ] && echo "FAIL check_no_data_layer_in_ui: data-layer imports in composable files:"
    printf '  %s:%s\n' "$f" "$(echo "$bad" | cut -d: -f1 | paste -sd, -)"
    hits=1
  fi
done < <(grep -rlZ '@Composable' "$target" --include='*.kt' 2>/dev/null)

[ $hits -ne 0 ] && exit 1
echo "PASS check_no_data_layer_in_ui"
exit 0
