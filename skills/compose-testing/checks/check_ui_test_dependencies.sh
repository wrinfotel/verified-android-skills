#!/usr/bin/env bash
# check_ui_test_dependencies.sh <project-or-src-dir>
# FLAGS: Compose UI tests present (imports androidx.compose.ui.test.*) in
# the target while its Gradle files do not declare ui-test-junit4 (rules)
# and ui-test-manifest (empty activity for createComposeRule()).
# Rule: SKILL.md §3.
# Source: https://developer.android.com/develop/ui/compose/testing
# Heuristic limitation: scans Gradle files up to 4 levels deep inside the
# target only (app/build.gradle.kts, libs.versions.toml, ...). No build
# files in the target -> skipped (PASS with note); the check cannot see
# sibling or parent modules.
set -uo pipefail
target="${1:?usage: check_ui_test_dependencies.sh <project-or-src-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

build_files=()
while IFS= read -r -d '' f; do
  build_files+=("$f")
done < <(find "$target" -maxdepth 4 \( -name '*.gradle' -o -name '*.gradle.kts' -o -name 'libs.versions.toml' \) -type f -print0 2>/dev/null)

if [ ${#build_files[@]} -eq 0 ]; then
  echo "PASS check_ui_test_dependencies (no build files in target; skipped)"
  exit 0
fi

if ! grep -rqs 'androidx\.compose\.ui\.test' "$target" --include='*.kt' 2>/dev/null; then
  echo "PASS check_ui_test_dependencies (no compose tests found)"
  exit 0
fi

missing=""
grep -hqE 'ui[.-]test[.-]junit4' "${build_files[@]}" 2>/dev/null || missing="ui-test-junit4"
grep -hqE 'ui[.-]test[.-]manifest' "${build_files[@]}" 2>/dev/null || missing="$missing ui-test-manifest"

if [ -n "${missing// /}" ]; then
  echo "FAIL check_ui_test_dependencies: compose tests found but dependencies missing from build files: $missing"
  printf '  build files scanned:\n'
  printf '    %s\n' "${build_files[@]}"
  exit 1
fi
echo "PASS check_ui_test_dependencies"
exit 0
