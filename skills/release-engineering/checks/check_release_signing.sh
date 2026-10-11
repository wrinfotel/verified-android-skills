#!/usr/bin/env bash
# check_release_signing.sh <project-or-module-dir>
# FLAGS: the release build type signing against the debug key
#        (signingConfigs.debug / getByName("debug")) — the debug key is
#        public knowledge; release must be signed with a release key.
# Rule: SKILL.md §2.
# Source: https://developer.android.com/studio/build — the debug build type
#   "is signed with the debug key"; "The release build type ... is not
#   signed by default" and requires explicit release signing for
#   distribution.
# Heuristic limitations: brace-matched scan of the release block (same
#   shapes as check_release_debuggable); signing configs injected from
#   convention plugins are not visible.
set -uo pipefail
target="${1:?usage: check_release_signing.sh <project-or-module-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=""
while IFS= read -r -d '' f; do
  m=$(awk '
    BEGIN { inrel=0; depth=0 }
    inrel==1 {
      if ($0 !~ /^[[:space:]]*\/\// && $0 ~ /signingConfig[[:space:]]*=?[[:space:]]*(signingConfigs\.)?(debug|getByName\([[:space:]]*"debug"[[:space:]]*\))/) print FILENAME ": " $0
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
  echo "FAIL check_release_signing: release build type signed with the debug key:"
  echo "$hits"
  exit 1
fi
echo "PASS check_release_signing"
exit 0
