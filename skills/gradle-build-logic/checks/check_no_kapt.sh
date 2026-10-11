#!/usr/bin/env bash
# check_no_kapt.sh <project-root>
# FLAGS: kapt usage in Gradle build files (kotlin("kapt"), kapt(), kaptTest,
# kaptAndroidTest) — kapt is significantly slower than KSP; use KSP for
# processors with KSP support (Room, Hilt, Moshi, ...).
# Rule: SKILL.md §2.
# Source: https://developer.android.com/build/optimize-your-build
#         ("migrate to KSP"; see also /build/migrate-to-ksp)
# Heuristic limitation: text-based; a processor without KSP support is a
# documented exception (SKILL.md §2) — annotate the declaration or scope
# the check. Full-line comments are ignored.
set -uo pipefail
target="${1:?usage: check_no_kapt.sh <project-root>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=0
while IFS= read -r -d '' f; do
  bad=$(grep -nE '\bkapt\b|\bkaptTest\b|\bkaptAndroidTest\b' "$f" 2>/dev/null \
    | grep -vE '(^|:)[0-9]+:[[:space:]]*(//|#)')
  if [ -n "$bad" ]; then
    [ $hits -eq 0 ] && echo "FAIL check_no_kapt: kapt found (use KSP for processors with KSP support):"
    printf '  %s:%s\n' "$f" "$(echo "$bad" | cut -d: -f1 | paste -sd, -)"
    hits=1
  fi
done < <(find "$target" \( -name '*.gradle' -o -name '*.gradle.kts' \) -type f -print0 2>/dev/null)

[ $hits -ne 0 ] && exit 1
echo "PASS check_no_kapt"
exit 0
