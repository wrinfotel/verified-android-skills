#!/usr/bin/env bash
# check_version_catalog.sh <project-root>
# FLAGS: hardcoded dependency coordinates with an embedded version
# ("group:artifact:version") in Gradle build files. Declare them in
# gradle/libs.versions.toml and reference via type-safe libs.* accessors.
# Dynamic versions ("group:artifact:1.+") are flagged by the same pattern.
# Rule: SKILL.md §1.
# Source: https://developer.android.com/build/migrate-to-catalogs
#         ("instead of hardcoding dependency names and versions in
#          individual build files ...")
# Heuristic limitation: string-literal based; URLs are excluded. A quoted
# non-dependency string with two colons would false-positive (none known).
# Full-line comments are ignored.
set -uo pipefail
target="${1:?usage: check_version_catalog.sh <project-root>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=0
while IFS= read -r -d '' f; do
  bad=$(grep -nE '"[^"]*:[^"]*:[^"]*"' "$f" 2>/dev/null \
    | grep -vE 'https?://' | grep -vE '(^|:)[0-9]+:[[:space:]]*(//|#)')
  if [ -n "$bad" ]; then
    [ $hits -eq 0 ] && echo "FAIL check_version_catalog: hardcoded dependency version (use gradle/libs.versions.toml + libs.* accessors):"
    printf '  %s:%s\n' "$f" "$(echo "$bad" | cut -d: -f1 | paste -sd, -)"
    hits=1
  fi
done < <(find "$target" \( -name '*.gradle' -o -name '*.gradle.kts' \) -type f -print0 2>/dev/null)

[ $hits -ne 0 ] && exit 1
echo "PASS check_version_catalog"
exit 0
