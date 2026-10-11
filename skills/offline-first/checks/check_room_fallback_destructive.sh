#!/usr/bin/env bash
# check_room_fallback_destructive.sh <kotlin-src-dir>
# FLAGS: the blanket fallbackToDestructiveMigration() on a Room builder —
#        when a migration is required and no path is defined, Room
#        permanently deletes all data from the database tables.
# Rule: SKILL.md §3 — migrations, not destruction.
# Source: https://developer.android.com/training/data-storage/room/migrating-db-versions —
#   warning that fallbackToDestructiveMigration makes Room "permanently
#   delete all data in the app's database tables" for undefined paths;
#   provide Migration objects via addMigrations(...) instead.
# Deliberate scope: only the blanket option is flagged. The targeted,
#   doc-endorsed variants (fallbackToDestructiveMigrationFrom,
#   fallbackToDestructiveMigrationOnDowngrade) do NOT match — the \b and
#   following character exclude the longer names.
set -uo pipefail
target="${1:?usage: check_room_fallback_destructive.sh <kotlin-src-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=$(grep -rnE '\bfallbackToDestructiveMigration\s*\(' "$target" --include='*.kt' --include='*.java' 2>/dev/null \
  | grep -vE '(^|:)[0-9]+:[[:space:]]*//' \
  | sed 's/^/  /')
if [ -n "$hits" ]; then
  echo "FAIL check_room_fallback_destructive: blanket destructive migration (drops all user data on unmigrated upgrades):"
  echo "$hits"
  exit 1
fi
echo "PASS check_room_fallback_destructive"
exit 0
