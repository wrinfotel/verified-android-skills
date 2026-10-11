#!/usr/bin/env bash
# check_no_sleep_in_instrumented.sh <test-src-dir>
# FLAGS: Thread.sleep / SystemClock.sleep in files importing androidx.test.*
#        (instrumented tests) — Espresso and UI Automator tests synchronize
#        through the framework (idle tracking, idling resources), not
#        wall-clock sleeps.
# Rule: SKILL.md §4 — no sleeps in instrumented tests.
# Source: https://developer.android.com/training/testing/espresso — Espresso
#   tracks the idle state of the app under test and "lets you stay away from
#   waits, syncs, sleeps and polls"; background work needs an IdlingResource.
# Heuristic limitation: files without an androidx.test import are never
#   flagged (plain JVM tests are out of scope here); kotlinx.coroutines.delay
#   is out of scope — the compose-testing skill covers it for Compose tests.
set -uo pipefail
target="${1:?usage: check_no_sleep_in_instrumented.sh <test-src-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=""
while IFS= read -r -d '' f; do
  grep -qE '^import[[:space:]]+androidx\.test\.' "$f" 2>/dev/null || continue
  m=$(grep -vE '^[[:space:]]*//' "$f" | grep -nE '\b(Thread|SystemClock)\.sleep\(' 2>/dev/null)
  if [ -n "$m" ]; then
    while IFS= read -r line; do
      [ -n "$line" ] || continue
      hits="${hits}  $f: $line
"
    done <<< "$m"
  fi
done < <(find "$target" -type f \( -name '*.kt' -o -name '*.java' \) -print0 2>/dev/null)

if [ -n "$hits" ]; then
  echo "FAIL check_no_sleep_in_instrumented: sleep() in an instrumented test (register an IdlingResource instead):"
  echo "$hits"
  exit 1
fi
echo "PASS check_no_sleep_in_instrumented"
exit 0
