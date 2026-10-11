#!/usr/bin/env bash
# check_no_android_only_compose_apis.sh <kmp-src-root>
# FLAGS: Android-only Compose APIs imported from commonMain/commonTest:
# LocalContext / LocalView / LocalConfiguration, androidx.compose.ui.res.*
# (Android stringResource/painterResource), and AndroidView. They are not
# available from common CMP code — use org.jetbrains.compose.resources.*,
# expect/actual, or the per-platform interop (UIKitView on iOS).
# Rule: SKILL.md §3.
# Source: https://kotlinlang.org/docs/multiplatform/compose-multiplatform-and-jetpack-compose.html
#         ("Android-only components ... are therefore not available from
#          common Compose Multiplatform code")
# Heuristic limitation: the flagged list is the documented heuristic
# subset of Android-only APIs, import-based. Extend for stricter setups.
# Full-line // comments are ignored.
set -uo pipefail
target="${1:?usage: check_no_android_only_compose_apis.sh <kmp-src-root>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=0
while IFS= read -r -d '' f; do
  bad=$(grep -nE '^import[[:space:]]+(androidx\.compose\.ui\.platform\.(LocalContext|LocalView|LocalConfiguration)\b|androidx\.compose\.ui\.res\.|androidx\.compose\.ui\.viewinterop\.AndroidView$)' "$f" 2>/dev/null \
    | grep -vE '(^|:)[0-9]+:[[:space:]]*//')
  if [ -n "$bad" ]; then
    [ $hits -eq 0 ] && echo "FAIL check_no_android_only_compose_apis: Android-only Compose APIs imported in a common source set:"
    printf '  %s:%s\n' "$f" "$(echo "$bad" | cut -d: -f1 | paste -sd, -)"
    hits=1
  fi
done < <(find "$target" \( -path '*/commonMain/*' -o -path '*/commonTest/*' \) -name '*.kt' -type f -print0 2>/dev/null)

[ $hits -ne 0 ] && exit 1
echo "PASS check_no_android_only_compose_apis"
exit 0
