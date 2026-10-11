#!/usr/bin/env bash
# check_release_minify.sh <project-root>
# FLAGS: application modules whose release build type does not enable R8
# (isMinifyEnabled/minifyEnabled = true) and resource shrinking
# (isShrinkResources/shrinkResources = true), or the AGP 9.3+
# `optimization { enable = true }` block. Tests and libraries are exempt.
# Rule: SKILL.md §3.
# Source: https://developer.android.com/studio/build/shrink-code
#         ("set isMinifyEnabled = true ... and isShrinkResources = true
#          ... always enable both settings")
# Heuristic limitation: per-file. If the release config lives in a
# convention plugin, run this check against the build-logic directory too.
# Full-line comments are ignored.
set -uo pipefail
target="${1:?usage: check_release_minify.sh <project-root>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=0
while IFS= read -r -d '' f; do
  grep -q 'com\.android\.application' "$f" 2>/dev/null || continue
  minify=$(grep -cE '(isMinifyEnabled|minifyEnabled)[[:space:]]*(=[[:space:]]*)?true' "$f" 2>/dev/null)
  shrink=$(grep -cE '(isShrinkResources|shrinkResources)[[:space:]]*(=[[:space:]]*)?true' "$f" 2>/dev/null)
  optblock=0
  grep -qE 'optimization[[:space:]]*\{' "$f" 2>/dev/null && grep -qE 'enable[[:space:]]*=[[:space:]]*true' "$f" 2>/dev/null && optblock=1
  if [ "$minify" -eq 0 ] || [ "$shrink" -eq 0 ]; then
    [ $optblock -eq 1 ] || {
      [ $hits -eq 0 ] && echo "FAIL check_release_minify: release build not fully optimized (R8 + resource shrinking):"
      printf '  %s missing: %s\n' "$f" "$([ "$minify" -eq 0 ] && printf 'minifyEnabled=true ' ; [ "$shrink" -eq 0 ] && printf 'shrinkResources=true')"
      hits=1
    }
  fi
done < <(find "$target" \( -name '*.gradle' -o -name '*.gradle.kts' \) -type f -print0 2>/dev/null)

[ $hits -ne 0 ] && exit 1
echo "PASS check_release_minify"
exit 0
