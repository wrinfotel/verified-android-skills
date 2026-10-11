#!/usr/bin/env bash
# check_test_dep_scope.sh <project-or-src-dir>
# FLAGS: test-only libraries on the production classpath — declared with
#        `implementation`/`api` instead of `testImplementation`/
#        `androidTestImplementation`.
# Rule: SKILL.md §2 — test frameworks must not ship in the APK.
# Sources:
#   https://developer.android.com/training/testing/set-up-project
#     (AndroidX Test + Espresso -> androidTestImplementation; documented
#      exception: espresso-idling-resource may be implementation)
#   https://developer.android.com/training/testing/local-tests
#     (JUnit, Mockito, MockK -> testImplementation)
# Heuristic limitations: dependency coordinates must be single-line strings
# (multiline dependency blocks yield false negatives); catalog aliases are
# matched by library name; project( and files( references are ignored.
set -uo pipefail
target="${1:?usage: check_test_dep_scope.sh <project-or-src-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

TOKEN='(junit|testng|mockito|mockk|robolectric|espresso|turbine|mockwebserver|kaspresso|uiautomator|androidx\.test|com\.google\.truth|org\.junit)'
found=0
hits=""

while IFS= read -r -d '' f; do
  found=$((found+1))
  # string-coordinate form: implementation("group:artifact:version"),
  # groovy implementation "group:artifact:version"
  while IFS= read -r coord; do
    [ -n "$coord" ] || continue
    if printf '%s' "$coord" | grep -Eq "(^|[^a-zA-Z])${TOKEN}"; then
      hits="${hits}  $f: $coord
"
    fi
  done < <(grep -nE '(^|[^A-Za-z0-9_.])(implementation|api)[[:space:]]*(\([[:space:]]*)?"[^"]*"' "$f" 2>/dev/null \
           | grep -vE '(^|:)[0-9]+:[[:space:]]*(//|#)' \
           | grep -vE 'project\(|files\(|idling' \
           | grep -oE '"[^"]*"')
  # catalog-alias form: implementation(libs.junit), implementation(libs.test.mockk)
  while IFS= read -r hit; do
    [ -n "$hit" ] || continue
    hits="${hits}  $f: $hit
"
  done < <(grep -nE "(^|[^A-Za-z0-9_.])(implementation|api)[[:space:]]*\\([[:space:]]*libs\\.[A-Za-z0-9.]*${TOKEN}" "$f" 2>/dev/null \
           | grep -vE '(^|:)[0-9]+:[[:space:]]*(//|#)' \
           | grep -vE 'idling' \
           | sed 's/^/  /')
done < <(find "$target" -maxdepth 4 -type f \( -name 'build.gradle.kts' -o -name 'build.gradle' \) -print0 2>/dev/null)

if [ "$found" -eq 0 ]; then
  echo "PASS check_test_dep_scope (no build files found — skipped)"
  exit 0
fi
if [ -n "$hits" ]; then
  echo "FAIL check_test_dep_scope: test-only library on the production classpath (use testImplementation / androidTestImplementation):"
  echo "$hits"
  exit 1
fi
echo "PASS check_test_dep_scope"
exit 0
