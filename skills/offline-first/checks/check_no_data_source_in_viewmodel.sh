#!/usr/bin/env bash
# check_no_data_source_in_viewmodel.sh <kotlin-src-dir>
# FLAGS: data-source imports (Retrofit, OkHttp, Ktor, Room, DataStore)
#        inside ViewModel files — state holders must read through
#        repositories; data sources belong to the data layer.
# Rule: SKILL.md §1 — repositories are the only data-layer entry point.
# Sources:
#   https://developer.android.com/topic/architecture/data-layer —
#     "other layers ... should not access data sources directly. The entry
#      points to the data layer are always repository classes"; state
#      holders "should never have a direct dependency on a data source".
#   https://developer.android.com/topic/architecture/data-layer/offline-first —
#     "the domain and UI layers of the app must never communicate directly
#      with the network layer".
# Heuristic limitations: file-level gate (@HiltViewModel or : ViewModel());
#   a ViewModel class sharing a file with a repository class is not
#   distinguished (Kotlin one-class-per-file makes this rare).
set -uo pipefail
target="${1:?usage: check_no_data_source_in_viewmodel.sh <kotlin-src-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=""
while IFS= read -r -d '' f; do
  grep -qE '@HiltViewModel|:[[:space:]]*(Android)?ViewModel[[:space:]]*\(' "$f" 2>/dev/null || continue
  m=$(grep -nE '^import[[:space:]]+(retrofit2\.|okhttp3\.|io\.ktor\.|androidx\.room\.|androidx\.datastore\.)' "$f" 2>/dev/null \
      | sed 's/^/    /')
  if [ -n "$m" ]; then
    hits="${hits}  $f: data-source import in a ViewModel — access data through a repository:
$m
"
  fi
done < <(find "$target" -type f -name '*.kt' -print0 2>/dev/null)

if [ -n "$hits" ]; then
  echo "FAIL check_no_data_source_in_viewmodel: data source accessed from a state holder:"
  echo "$hits"
  exit 1
fi
echo "PASS check_no_data_source_in_viewmodel"
exit 0
