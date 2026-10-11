#!/usr/bin/env bash
# check_datastore_dup_names.sh <kotlin-src-dir>
# FLAGS: two or more DataStore delegates sharing a name/file — preferences
#        DataStore names and typed DataStore fileName values must be unique
#        across the app; duplicates break all DataStore functionality.
# Rule: SKILL.md §4 — one DataStore instance per file.
# Source: https://developer.android.com/topic/libraries/architecture/datastore —
#   "Never create more than one instance of DataStore for a given file in
#    the same process ... DataStore will throw IllegalStateException when
#    reading or updating data."
# Heuristic limitations: detects duplicate `preferencesDataStore(name = ...)`
#   and `dataStore(fileName = ...)` string values; delegates built with
#   computed names are not visible.
set -uo pipefail
target="${1:?usage: check_datastore_dup_names.sh <kotlin-src-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

tmp=$(mktemp)
while IFS= read -r -d '' f; do
  grep -vE '^[[:space:]]*//' "$f" 2>/dev/null \
    | grep -oE '(preferencesDataStore[[:space:]]*\([[:space:]]*name[[:space:]]*=[[:space:]]*"|dataStore[[:space:]]*\([[:space:]]*fileName[[:space:]]*=[[:space:]]*")[^"]*"' \
    | sed -E 's/.*"([^"]*)"/\1/' \
    | while IFS= read -r n; do
        [ -n "$n" ] && printf '  %s: "%s"\n' "$f" "$n"
      done
done < <(find "$target" -type f -name '*.kt' -print0 2>/dev/null) > "$tmp" 2>/dev/null

if [ ! -s "$tmp" ]; then
  rm -f "$tmp"
  echo "PASS check_datastore_dup_names"
  exit 0
fi

dups=$(awk '{print $NF}' "$tmp" | sort | uniq -d)
if [ -n "$dups" ]; then
  echo "FAIL check_datastore_dup_names: multiple DataStore instances for the same file/name (IllegalStateException at runtime):"
  sort "$tmp" | uniq | grep -F -f <(printf '%s\n' "$dups")
  rm -f "$tmp"
  exit 1
fi
rm -f "$tmp"
echo "PASS check_datastore_dup_names"
exit 0
