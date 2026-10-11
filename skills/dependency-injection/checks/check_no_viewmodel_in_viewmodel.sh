#!/usr/bin/env bash
# check_no_viewmodel_in_viewmodel.sh <kotlin-src-dir>
# FLAGS: a ViewModel-typed constructor parameter in a @HiltViewModel class —
#        ViewModels are platform-managed and must not be passed to other
#        classes; share a repository instead.
# Rule: SKILL.md §4.
# Source: https://developer.android.com/topic/libraries/architecture/viewmodel —
#   "Don't pass ViewModels to other classes, functions or other UI
#    components. Because the platform manages them, you should keep them
#    as close to it as you can."
# Heuristic limitations: @HiltViewModel files only; a ViewModelProvider.Factory
#   class sharing the same file as its ViewModel is not distinguished
#   (rare in Hilt projects); nested types like FooViewModel.State do not
#   match (type must be followed by a parameter separator).
set -uo pipefail
target="${1:?usage: check_no_viewmodel_in_viewmodel.sh <kotlin-src-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=""
while IFS= read -r -d '' f; do
  grep -qE '@HiltViewModel' "$f" 2>/dev/null || continue
  m=$(grep -vE '^[[:space:]]*//' "$f" 2>/dev/null \
      | grep -zoE '(class[[:space:]]+[A-Za-z0-9_]+[[:space:]]*\(|constructor[[:space:]]*\()[^)]*\b[A-Za-z0-9_]+ViewModel[[:space:]]*[:,)]' 2>/dev/null \
      | tr '\0' '\n' | sed 's/^/    /')
  if [ -n "$m" ]; then
    hits="${hits}  $f: ViewModel injected into another ViewModel — share a repository instead:
$m
"
  fi
done < <(find "$target" -type f \( -name '*.kt' -o -name '*.java' \) -print0 2>/dev/null)

if [ -n "$hits" ]; then
  echo "FAIL check_no_viewmodel_in_viewmodel: ViewModel passed to another class:"
  echo "$hits"
  exit 1
fi
echo "PASS check_no_viewmodel_in_viewmodel"
exit 0
