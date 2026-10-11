#!/usr/bin/env bash
# check_viewmodel_construction.sh <kotlin-src-dir>
# FLAGS: direct ViewModel construction (`= FooViewModel(...)`) in Kotlin
# sources — ViewModels must come from viewModel()/hiltViewModel() or DI.
# Rule: SKILL.md §3 — manual construction breaks config-change retention
# and instance sharing.
# Source: https://developer.android.com/topic/libraries/architecture/viewmodel
#         https://developer.android.com/develop/ui/compose/state
# Heuristic limitation: single-line `= Type(...)` shape only; multiline
# constructor calls may be missed. Class declarations (`class FooViewModel`)
# and `: ViewModel()` supertypes do not match. Full-line // comments are
# ignored; inline comments after a real call site still count.
set -uo pipefail
target="${1:?usage: check_viewmodel_construction.sh <kotlin-src-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=$(grep -rnE '=\s*[A-Z][A-Za-z0-9_]*ViewModel\s*\(' "$target" --include='*.kt' 2>/dev/null \
  | grep -vE ':[0-9]+:[[:space:]]*//' | sed 's/^/  /')
if [ -n "$hits" ]; then
  echo "FAIL check_viewmodel_construction: ViewModel constructed manually (use viewModel()/hiltViewModel()):"
  echo "$hits"
  exit 1
fi
echo "PASS check_viewmodel_construction"
exit 0
