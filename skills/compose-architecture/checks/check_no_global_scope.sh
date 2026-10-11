#!/usr/bin/env bash
# check_no_global_scope.sh <kotlin-src-dir>
# FLAGS: `GlobalScope` usage — unmanaged coroutine lifetime. UI code must
# use rememberCoroutineScope()/LaunchedEffect, business code a managed
# scope tied to a lifecycle owner.
# Rule: SKILL.md §3.
# Source: https://developer.android.com/develop/ui/compose/side-effects
# Heuristic limitation: full-line // comments are ignored; inline comments
# after real usage still count.
set -uo pipefail
target="${1:?usage: check_no_global_scope.sh <kotlin-src-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=$(grep -rn 'GlobalScope' "$target" --include='*.kt' 2>/dev/null \
  | grep -vE ':[0-9]+:[[:space:]]*//' | sed 's/^/  /')
if [ -n "$hits" ]; then
  echo "FAIL check_no_global_scope: GlobalScope found (unmanaged coroutine lifetime):"
  echo "$hits"
  exit 1
fi
echo "PASS check_no_global_scope"
exit 0
