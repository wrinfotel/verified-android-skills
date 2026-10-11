#!/usr/bin/env bash
# check_collect_as_state_lifecycle.sh <kotlin-src-dir>
# FLAGS: `.collectAsState()` / bare `collectAsState(` — flows collected
# without lifecycle awareness; they keep collecting while the UI is
# stopped. Use collectAsStateWithLifecycle() on Android.
# Rule: SKILL.md §4.
# Source: https://developer.android.com/develop/ui/compose/state
#         ("recommended way to collect flows on Android apps")
# Heuristic limitation: KMP-common code legitimately uses collectAsState()
# (SKILL.md §4) — scope this check to Android sources. Full-line //
# comments are ignored; inline comments after a real call site still count.
set -uo pipefail
target="${1:?usage: check_collect_as_state_lifecycle.sh <kotlin-src-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=$(grep -rnE '\.collectAsState\(|(^|[^.A-Za-z])collectAsState\(' "$target" --include='*.kt' 2>/dev/null \
  | grep -vE ':[0-9]+:[[:space:]]*//' | sed 's/^/  /')
if [ -n "$hits" ]; then
  echo "FAIL check_collect_as_state_lifecycle: collectAsState() used (keeps collecting while stopped):"
  echo "$hits"
  exit 1
fi
echo "PASS check_collect_as_state_lifecycle"
exit 0
