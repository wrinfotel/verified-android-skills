#!/usr/bin/env bash
# check_androidview_factory_state.sh <kotlin-src-dir>
# FLAGS: state reads inside the AndroidView factory lambda (single-line
# `factory = { ... .value ... }` shapes) — the factory runs once at
# instantiation, so state read there goes stale; read it in `update`.
# Rule: SKILL.md §2.
# Source: https://developer.android.com/develop/ui/compose/migrate/interoperability-apis/views-in-compose
# Heuristic limitation: single-line factory lambdas only; multiline
# factories are not inspected (false negatives possible). Full-line //
# comments are ignored.
set -uo pipefail
target="${1:?usage: check_androidview_factory_state.sh <kotlin-src-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=0
while IFS= read -r -d '' f; do
  grep -qE 'AndroidView\s*\(' "$f" 2>/dev/null || continue
  bad=$(grep -nE 'factory\s*=\s*\{[^}]*\.value\b' "$f" 2>/dev/null \
    | grep -vE '(^|:)[0-9]+:[[:space:]]*//')
  if [ -n "$bad" ]; then
    [ $hits -eq 0 ] && echo "FAIL check_androidview_factory_state: state read inside AndroidView factory (goes stale; use update):"
    printf '  %s:%s\n' "$f" "$(echo "$bad" | cut -d: -f1 | paste -sd, -)"
    hits=1
  fi
done < <(find "$target" -name '*.kt' -type f -print0 2>/dev/null)

[ $hits -ne 0 ] && exit 1
echo "PASS check_androidview_factory_state"
exit 0
