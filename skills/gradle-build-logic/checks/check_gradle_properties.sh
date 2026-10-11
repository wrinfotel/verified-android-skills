#!/usr/bin/env bash
# check_gradle_properties.sh <project-root>
# FLAGS: gradle.properties that does not enable the build-speed flags:
# org.gradle.caching=true (build cache is off by default),
# org.gradle.parallel=true (parallel subproject execution), and
# org.gradle.configuration-cache=true.
# Rule: SKILL.md §4.
# Source: https://docs.gradle.org/current/userguide/performance.html
#         https://developer.android.com/build/optimize-your-build
# Heuristic limitation: scans gradle.properties up to 2 levels deep in the
# target; no such file -> skipped (PASS with note).
set -uo pipefail
target="${1:?usage: check_gradle_properties.sh <project-root>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

props=""
while IFS= read -r -d '' f; do
  props="$f"
done < <(find "$target" -maxdepth 2 -name 'gradle.properties' -type f -print0 2>/dev/null)

if [ -z "$props" ]; then
  echo "PASS check_gradle_properties (no gradle.properties in target; skipped)"
  exit 0
fi

missing=""
grep -qE 'org\.gradle\.caching[[:space:]]*=[[:space:]]*true' "$props" 2>/dev/null || missing="org.gradle.caching=true"
grep -qE 'org\.gradle\.parallel[[:space:]]*=[[:space:]]*true' "$props" 2>/dev/null || missing="$missing org.gradle.parallel=true"
grep -qE 'org\.gradle\.configuration-cache[[:space:]]*=[[:space:]]*true' "$props" 2>/dev/null || missing="$missing org.gradle.configuration-cache=true"

if [ -n "${missing// /}" ]; then
  echo "FAIL check_gradle_properties: build-speed flags missing from $props: $missing"
  exit 1
fi
echo "PASS check_gradle_properties"
exit 0
