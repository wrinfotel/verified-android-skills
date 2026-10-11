#!/usr/bin/env bash
# check_expect_actual_placement.sh <kmp-src-root>
# FLAGS: `actual` declarations in commonMain/commonTest and `expect`
# declarations in platform source sets (androidMain, iosMain, jvmMain,
# ...) — expect belongs in the common source set, actual in each
# platform-specific source set, same package.
# Rule: SKILL.md §2.
# Source: https://kotlinlang.org/docs/multiplatform/multiplatform-expect-actual.html
# Heuristic limitation: path-based; intermediate source sets (appleMain,
# nativeMain) are treated as platform sets. Full-line // comments are
# ignored.
set -uo pipefail
target="${1:?usage: check_expect_actual_placement.sh <kmp-src-root>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=0
# actual in a common source set
while IFS= read -r -d '' f; do
  bad=$(grep -nE '\bactual[[:space:]]+(fun|val|var|class|interface|object|typealias)\b' "$f" 2>/dev/null \
    | grep -vE '(^|:)[0-9]+:[[:space:]]*//')
  if [ -n "$bad" ]; then
    [ $hits -eq 0 ] && echo "FAIL check_expect_actual_placement: actual declarations in a common source set:"
    printf '  %s:%s\n' "$f" "$(echo "$bad" | cut -d: -f1 | paste -sd, -)"
    hits=1
  fi
done < <(find "$target" \( -path '*/commonMain/*' -o -path '*/commonTest/*' \) -name '*.kt' -type f -print0 2>/dev/null)

# expect in a platform source set
while IFS= read -r -d '' f; do
  bad=$(grep -nE '\bexpect[[:space:]]+(fun|val|var|class|interface|object|typealias)\b' "$f" 2>/dev/null \
    | grep -vE '(^|:)[0-9]+:[[:space:]]*//')
  if [ -n "$bad" ]; then
    [ $hits -eq 0 ] && echo "FAIL check_expect_actual_placement: expect declarations in a platform source set:"
    printf '  %s:%s\n' "$f" "$(echo "$bad" | cut -d: -f1 | paste -sd, -)"
    hits=1
  fi
done < <(find "$target" \( -path '*/androidMain/*' -o -path '*/iosMain/*' -o -path '*/jvmMain/*' -o -path '*/jsMain/*' -o -path '*/wasmJsMain/*' -o -path '*/nativeMain/*' -o -path '*/appleMain/*' -o -path '*/macosMain/*' -o -path '*/watchosMain/*' -o -path '*/tvosMain/*' -o -path '*/linuxMain/*' -o -path '*/mingwXMain/*' -o -path '*/desktopMain/*' \) -name '*.kt' -type f -print0 2>/dev/null)

[ $hits -ne 0 ] && exit 1
echo "PASS check_expect_actual_placement"
exit 0
