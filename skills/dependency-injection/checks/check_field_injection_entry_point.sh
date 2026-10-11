#!/usr/bin/env bash
# check_field_injection_entry_point.sh <kotlin-src-dir>
# FLAGS: @Inject field declarations (lateinit var / var / val) in a file
#        without @AndroidEntryPoint or @HiltAndroidApp — the field is never
#        populated and crashes at first use.
# Rule: SKILL.md §1 — field injection only in entry points.
# Source: https://developer.android.com/training/dependency-injection/hilt-android —
#   "Hilt can provide dependencies to other Android classes that have the
#    @AndroidEntryPoint annotation"; field-injection example lives inside
#    an @AndroidEntryPoint activity.
# Heuristic limitations: Kotlin field forms only (`@Inject lateinit var`,
# `@Inject var/val`); constructor injection (`@Inject constructor(...)`)
# is never flagged. Full-line comments are filtered; a field declaration
# quoted in a trailing comment on a code line still flags.
set -uo pipefail
target="${1:?usage: check_field_injection_entry_point.sh <kotlin-src-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=""
while IFS= read -r -d '' f; do
  grep -qE '@(AndroidEntryPoint|HiltAndroidApp)' "$f" 2>/dev/null && continue
  m=$(grep -vE '^[[:space:]]*//' "$f" 2>/dev/null \
      | grep -zoE '@Inject[[:space:]]*(lateinit[[:space:]]+var|var|val)[[:space:]]+[A-Za-z_][A-Za-z0-9_]*' 2>/dev/null \
      | tr '\0' '\n' | sed 's/^/    /')
  if [ -n "$m" ]; then
    hits="${hits}  $f: @Inject field outside an entry point — annotate the class @AndroidEntryPoint or use constructor injection:
$m
"
  fi
done < <(find "$target" -type f \( -name '*.kt' -o -name '*.java' \) -print0 2>/dev/null)

if [ -n "$hits" ]; then
  echo "FAIL check_field_injection_entry_point: @Inject field outside an entry point:"
  echo "$hits"
  exit 1
fi
echo "PASS check_field_injection_entry_point"
exit 0
