#!/usr/bin/env bash
# check_robolectric_source_set.sh <project-or-src-dir>
# FLAGS: Robolectric imports under src/androidTest — Robolectric runs in a
#        JVM (local tests), so Robolectric tests belong in src/test.
# Rule: SKILL.md §1 — Robolectric is a local-test tool.
# Source: https://developer.android.com/training/testing/local-tests/robolectric —
#   "You can convert an instrumented test to Robolectric by moving it to
#    the test source set and setting up the Robolectric dependencies."
# Heuristic limitation: catches files importing org.robolectric.*; Robolectric
# tests run through AndroidJUnit4 with no robolectric import are not detected.
set -uo pipefail
target="${1:?usage: check_robolectric_source_set.sh <project-or-src-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=""
count=0
while IFS= read -r -d '' f; do
  count=$((count+1))
  if grep -vE '^[[:space:]]*//' "$f" 2>/dev/null | grep -qE 'org\.robolectric\.'; then
    hits="${hits}  $f: Robolectric test in src/androidTest — move to src/test
"
  fi
done < <(find "$target" -type f \( -name '*.kt' -o -name '*.java' \) -path '*src/androidTest*' -print0 2>/dev/null)

if [ "$count" -eq 0 ]; then
  echo "PASS check_robolectric_source_set (no src/androidTest files found — skipped)"
  exit 0
fi
if [ -n "$hits" ]; then
  echo "FAIL check_robolectric_source_set: Robolectric test in the instrumented source set:"
  echo "$hits"
  exit 1
fi
echo "PASS check_robolectric_source_set"
exit 0
