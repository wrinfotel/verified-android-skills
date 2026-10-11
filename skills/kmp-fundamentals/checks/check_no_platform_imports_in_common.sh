#!/usr/bin/env bash
# check_no_platform_imports_in_common.sh <kmp-src-root>
# FLAGS: platform SDK imports (android.*, java.*, javax.*, platform.*,
# com.android.*, com.google.android.*, androidx.activity.*) inside
# commonMain / commonTest — common code compiles to every target where
# those SDKs do not exist. Use multiplatform libraries instead.
# Rule: SKILL.md §1.
# Source: https://kotlinlang.org/docs/multiplatform/multiplatform-discover-project.html
#         (the java.io.File example; platform source sets only)
# Heuristic limitation: androidx.compose.* and other Compose Multiplatform
# artifacts ship a common API and are intentionally NOT flagged; extend
# the pattern for stricter setups. Full-line // comments are ignored.
set -uo pipefail
target="${1:?usage: check_no_platform_imports_in_common.sh <kmp-src-root>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=0
while IFS= read -r -d '' f; do
  bad=$(grep -nE '^import[[:space:]]+(android\.|androidx\.activity\.|java\.|javax\.|platform\.|com\.android\.|com\.google\.android\.)' "$f" 2>/dev/null \
    | grep -vE '(^|:)[0-9]+:[[:space:]]*//')
  if [ -n "$bad" ]; then
    [ $hits -eq 0 ] && echo "FAIL check_no_platform_imports_in_common: platform SDK imports in a common source set:"
    printf '  %s:%s\n' "$f" "$(echo "$bad" | cut -d: -f1 | paste -sd, -)"
    hits=1
  fi
done < <(find "$target" \( -path '*/commonMain/*' -o -path '*/commonTest/*' \) -name '*.kt' -type f -print0 2>/dev/null)

[ $hits -ne 0 ] && exit 1
echo "PASS check_no_platform_imports_in_common"
exit 0
