#!/usr/bin/env bash
# check_release_debuggable.sh <project-or-module-dir>
# FLAGS: isDebuggable = true inside a `release` build-type block — the
#        release type is the distribution build; debugging tools belong to
#        the debug build type.
# Rule: SKILL.md §1.
# Source: https://developer.android.com/studio/build — "The debug build
#   type ... includes debugging tools and is signed with the debug key";
#   "The release build type applies ProGuard settings and is not signed by
#   default."
# Heuristic limitations: brace-matched scan of build.gradle[.kts] files
#   (handles release {, getByName("release") {, create("release") {);
#   full-line comments inside the block are ignored.
set -uo pipefail
target="${1:?usage: check_release_debuggable.sh <project-or-module-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=""
while IFS= read -r -d '' f; do
  m=$(awk '
    BEGIN { inrel=0; depth=0 }
    inrel==1 {
      if ($0 !~ /^[[:space:]]*\/\// && $0 ~ /(isDebuggable[[:space:]]*=[[:space:]]*true|debuggable[[:space:]]+true)/) print FILENAME ": " $0
      depth += gsub(/\{/, "{"); depth -= gsub(/\}/, "}")
      if (depth <= 0) inrel=0
      next
    }
    {
      if ($0 ~ /(^|[^A-Za-z0-9_])release[[:space:]]*"?[[:space:]]*\)?[[:space:]]*\{/) {
        inrel=1
        depth = gsub(/\{/, "{") - gsub(/\}/, "}")
        if (depth <= 0) inrel=0
      }
    }
  ' "$f" 2>/dev/null)
  if [ -n "$m" ]; then
    hits="${hits}  $m
"
  fi
done < <(find "$target" -maxdepth 4 -type f \( -name 'build.gradle.kts' -o -name 'build.gradle' \) -print0 2>/dev/null)

if [ -n "$hits" ]; then
  echo "FAIL check_release_debuggable: debug tooling enabled in the release build type:"
  echo "$hits"
  exit 1
fi
echo "PASS check_release_debuggable"
exit 0
