#!/usr/bin/env bash
# check_provides_in_module.sh <kotlin-src-dir>
# FLAGS: @Provides / @Binds methods in a file without @Module — providers
#        must live inside a module class (which also carries @InstallIn).
# Rule: SKILL.md §3.
# Source: https://developer.android.com/training/dependency-injection/hilt-android —
#   "A Hilt module is a class that is annotated with @Module ... You must
#    also annotate every module with @InstallIn"; @Binds / @Provides
#   examples are inside @Module classes.
# Heuristic limitation: file-level — @Provides methods of a module defined
#   in a different file are not visible (Kotlin one-class-per-file makes
#   this the dominant shape).
set -uo pipefail
target="${1:?usage: check_provides_in_module.sh <kotlin-src-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=""
while IFS= read -r -d '' f; do
  body=$(grep -vE '^[[:space:]]*//' "$f" 2>/dev/null)
  printf '%s' "$body" | grep -qE '@(Provides|Binds)[[:space:]]*$|@(Provides|Binds)[[:space:]]' 2>/dev/null || continue
  if ! printf '%s' "$body" | grep -qE '@Module\b'; then
    hits="${hits}  $f: @Provides/@Binds outside a @Module
"
  fi
done < <(find "$target" -type f \( -name '*.kt' -o -name '*.java' \) -print0 2>/dev/null)

if [ -n "$hits" ]; then
  echo "FAIL check_provides_in_module: provider methods outside a @Module:"
  echo "$hits"
  exit 1
fi
echo "PASS check_provides_in_module"
exit 0
