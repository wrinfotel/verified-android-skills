#!/usr/bin/env bash
# check_manifest_exported.sh <project-or-module-dir>
# FLAGS: activity / activity-alias / service / receiver elements with an
#        <intent-filter> but no android:exported attribute — apps targeting
#        Android 12+ cannot be installed.
# Rule: SKILL.md §4.
# Source: https://developer.android.com/about/versions/12/behavior-changes-12 —
#   "If your app targets Android 12 or higher and contains activities,
#    services, or broadcast receivers that use intent filters, you must
#    explicitly declare the android:exported attribute"; without it the
#   app "can't be installed on a device that runs Android 12 or higher".
# Heuristic limitations: multi-line manifest formatting assumed (an
#   intent-filter written on the same line as the component tag is not
#   seen); XML comments are skipped; activity-alias is included (behaves
#   like an activity for intent filters, enforced by the manifest merger).
set -uo pipefail
target="${1:?usage: check_manifest_exported.sh <project-or-module-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=""
while IFS= read -r -d '' f; do
  m=$(awk '
    BEGIN { state=0; incomment=0; hasExported=0; hasFilter=0; buf=""; elemtag="" }
    function getname(s) {
      if (match(s, /android:name="[^"]*"/)) return substr(s, RSTART+13, RLENGTH-14)
      return "?"
    }
    {
      line=$0
      if (incomment==1) { if (line ~ /-->/) incomment=0; next }
      if (line ~ /<!--/) { if (line !~ /-->/) incomment=1; next }
      if (state==1) {
        buf = buf " " line
        if (line ~ /android:exported/) hasExported=1
        if (line ~ />/) {
          if (buf ~ /\/>[[:space:]]*$/) { state=0; buf="" } else { state=2 }
        }
        next
      }
      if (state==2) {
        if (line ~ /<intent-filter/) hasFilter=1
        if (elemtag != "" && line ~ ("</" elemtag)) {
          if (hasFilter==1 && hasExported==0) print FILENAME ": <" elemtag "> with <intent-filter> missing android:exported: " getname(buf)
          state=0; buf=""
        }
        next
      }
      if (match(line, /<(activity-alias|activity|service|receiver)([[:space:]>]|$)/)) {
        tmp = substr(line, RSTART+1)
        match(tmp, /^[A-Za-z-]+/)
        elemtag = substr(tmp, 1, RLENGTH)
        state=1; buf=line; hasFilter=0
        hasExported = (line ~ /android:exported/) ? 1 : 0
        if (line ~ />/) {
          if (buf ~ /\/>[[:space:]]*$/) { state=0; buf="" } else { state=2 }
        }
      }
    }
  ' "$f" 2>/dev/null)
  if [ -n "$m" ]; then
    hits="${hits}  $m
"
  fi
done < <(find "$target" -type f -name 'AndroidManifest.xml' -not -path '*src/debug*' -print0 2>/dev/null)

if [ -n "$hits" ]; then
  echo "FAIL check_manifest_exported: intent-filtered component without android:exported (install failure on Android 12+):"
  echo "$hits"
  exit 1
fi
echo "PASS check_manifest_exported"
exit 0
