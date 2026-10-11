#!/usr/bin/env bash
# check_no_sleep_in_compose_tests.sh <kotlin-src-dir>
# FLAGS: Thread.sleep / SystemClock.sleep / delay( inside files that
# import androidx.compose.ui.test — real-time blocking of a test that
# runs on a virtual clock. Use waitUntil helpers / mainClock instead.
# Rule: SKILL.md §1.
# Source: https://developer.android.com/develop/ui/compose/testing/synchronization
# Heuristic limitation: any `delay(` in a compose test file is flagged,
# including delays inside fakes (documented: drive the clock instead).
# Full-line // comments are ignored; inline comments still count.
set -uo pipefail
target="${1:?usage: check_no_sleep_in_compose_tests.sh <kotlin-src-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=0
while IFS= read -r -d '' f; do
  bad=$(grep -nE '\b(Thread|SystemClock)\.sleep\(|\bdelay\(' "$f" 2>/dev/null \
    | grep -vE '(^|:)[0-9]+:[[:space:]]*//')
  if [ -n "$bad" ]; then
    [ $hits -eq 0 ] && echo "FAIL check_no_sleep_in_compose_tests: blocking call in a compose test (use waitUntil/mainClock):"
    printf '  %s:%s\n' "$f" "$(echo "$bad" | cut -d: -f1 | paste -sd, -)"
    hits=1
  fi
done < <(grep -rlZ '^import androidx\.compose\.ui\.test' "$target" --include='*.kt' 2>/dev/null)

[ $hits -ne 0 ] && exit 1
echo "PASS check_no_sleep_in_compose_tests"
exit 0
