#!/usr/bin/env bash
# check_room_allow_main_thread.sh <kotlin-src-dir>
# FLAGS: allowMainThreadQueries() on a Room database builder — Room does not
#        support database access on the main thread; the escape hatch
#        reintroduces UI jank and ANRs.
# Rule: SKILL.md §2.
# Source: https://developer.android.com/training/data-storage/room/async-queries —
#   "To prevent queries from blocking the UI, Room does not support
#    database access on the main thread."
# Heuristic limitation: none known — the call has no legitimate shape and
#   matches even inside multiline builder chains.
set -uo pipefail
target="${1:?usage: check_room_allow_main_thread.sh <kotlin-src-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=$(grep -rnE '\ballowMainThreadQueries\s*\(' "$target" --include='*.kt' --include='*.java' 2>/dev/null \
  | grep -vE '(^|:)[0-9]+:[[:space:]]*//' \
  | sed 's/^/  /')
if [ -n "$hits" ]; then
  echo "FAIL check_room_allow_main_thread: main-thread database access enabled:"
  echo "$hits"
  exit 1
fi
echo "PASS check_room_allow_main_thread"
exit 0
