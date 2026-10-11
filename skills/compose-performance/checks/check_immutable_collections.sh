#!/usr/bin/env bash
# check_immutable_collections.sh <kotlin-src-dir>
# FLAGS: (a) mutable collection types in composable parameter positions,
#        (b) `remember { mutableListOf/mapOf/setOf }` feeding the UI.
# Rule: SKILL.md §1 — prefer ImmutableList / state holders.
# Heuristic limitation: matches by signature text; a `MutableList` param on a
# non-composable function is reported too (rare, and still worth a look).
set -uo pipefail
target="${1:?usage: check_immutable_collections.sh <kotlin-src-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=""
# (a) mutable collection types anywhere in composable signatures / params
h1=$(grep -rnE '@Composable|fun [A-Za-z_]+\(' "$target" --include='*.kt' -A6 2>/dev/null \
  | grep -E ':\s*Mutable(List|Map|Set)<' | sed 's/^/  /')
[ -n "$h1" ] && hits+="mutable collection type in a composable signature:
$h1
"
# (b) remember { mutableListOf(...) } pattern
h2=$(grep -rnE 'remember\s*(\(|\{)[^)]*\{\s*mutable(List|Map|Set)Of' "$target" --include='*.kt' 2>/dev/null \
  | sed 's/^/  /')
[ -n "$h2" ] && hits+="remember { mutable*Of } feeding UI state:
$h2
"

if [ -n "$hits" ]; then
  echo "FAIL check_immutable_collections:"
  printf '%s\n' "$hits"
  exit 1
fi
echo "PASS check_immutable_collections"
exit 0
