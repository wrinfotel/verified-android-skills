#!/usr/bin/env bash
# check_hilt_viewmodel_inject.sh <kotlin-src-dir>
# FLAGS: @HiltViewModel without an `@Inject constructor` — @HiltViewModel only
#        registers the ViewModel with the ViewModelComponent; the @Inject
#        constructor is what tells Hilt how to build it.
# Rule: SKILL.md §2.
# Source: https://developer.android.com/training/dependency-injection/hilt-jetpack —
#   "Provide a ViewModel by annotating it with @HiltViewModel and using the
#    @Inject annotation in the ViewModel object's constructor."
# Heuristic limitation: file-level (a @HiltViewModel class sharing a file
#   with an unannotated second ViewModel class is not distinguished).
set -uo pipefail
target="${1:?usage: check_hilt_viewmodel_inject.sh <kotlin-src-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=""
while IFS= read -r -d '' f; do
  grep -qE '@HiltViewModel' "$f" 2>/dev/null || continue
  if ! grep -vE '^[[:space:]]*//' "$f" 2>/dev/null | grep -zqE '@Inject[[:space:]]+constructor'; then
    hits="${hits}  $f: @HiltViewModel without @Inject constructor — Hilt cannot build this ViewModel
"
  fi
done < <(find "$target" -type f \( -name '*.kt' -o -name '*.java' \) -print0 2>/dev/null)

if [ -n "$hits" ]; then
  echo "FAIL check_hilt_viewmodel_inject: @HiltViewModel missing @Inject constructor:"
  echo "$hits"
  exit 1
fi
echo "PASS check_hilt_viewmodel_inject"
exit 0
