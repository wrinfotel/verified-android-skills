#!/usr/bin/env bash
# check_cleartext_traffic.sh <project-or-module-dir>
# FLAGS: android:usesCleartextTraffic="true" in manifests outside the
#        debug source set — cleartext HTTP is disabled by default since
#        API 28 and app-wide re-enabling is documented as insecure.
# Rule: SKILL.md §3.
# Source: https://developer.android.com/privacy-and-security/security-config —
#   "Starting with Android 9 (API level 28), cleartext support is disabled
#    by default"; blanket opt-in "should be avoided whenever possible"
#    (prefer a scoped domain-config).
# Heuristic limitations: src/debug manifests are exempt by path (local dev
#   against plain HTTP is normal); a network security config with a broad
#   base-config cleartextTrafficPermitted="true" is not detected here.
set -uo pipefail
target="${1:?usage: check_cleartext_traffic.sh <project-or-module-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=""
while IFS= read -r -d '' f; do
  m=$(grep -nE 'android:usesCleartextTraffic="true"' "$f" 2>/dev/null \
      | grep -vE '(^|:)[0-9]+:[[:space:]]*<!--' \
      | sed 's/^/    /')
  if [ -n "$m" ]; then
    hits="${hits}  $f: cleartext HTTP enabled outside debug sourceset:
$m
"
  fi
done < <(find "$target" -type f -name 'AndroidManifest.xml' -not -path '*src/debug*' -print0 2>/dev/null)

if [ -n "$hits" ]; then
  echo "FAIL check_cleartext_traffic: usesCleartextTraffic=true in a non-debug manifest:"
  echo "$hits"
  exit 1
fi
echo "PASS check_cleartext_traffic"
exit 0
