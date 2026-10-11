#!/usr/bin/env bash
# check_no_r_class_in_common.sh <kmp-src-root>
# FLAGS: Android R-class resources inside commonMain/commonTest — imports
# like `import com.example.app.R` (and nested `...R.string`) and usages
# `R.drawable.` / `R.string.` / `R.color.` / `R.layout.` etc. Use the
# generated Res accessors with painterResource/stringResource from
# org.jetbrains.compose.resources.
# Rule: SKILL.md §2.
# Source: https://kotlinlang.org/docs/multiplatform/compose-multiplatform-and-jetpack-compose.html
#         ("Compose Multiplatform uses the Res class ...; Android uses
#          the R class")
# Heuristic limitation: `Res.string` / `XxxRes.string` do not match the
# `R.` pattern by construction. Full-line // comments are ignored.
set -uo pipefail
target="${1:?usage: check_no_r_class_in_common.sh <kmp-src-root>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=0
while IFS= read -r -d '' f; do
  bad=$(grep -nE '(^import[[:space:]]+[a-z][a-z0-9_.]*\.R($|\.)|\bR\.(drawable|string|color|layout|mipmap|font|style|id)\.)' "$f" 2>/dev/null \
    | grep -vE '(^|:)[0-9]+:[[:space:]]*//')
  if [ -n "$bad" ]; then
    [ $hits -eq 0 ] && echo "FAIL check_no_r_class_in_common: Android R-class resources in a common source set (use Res + org.jetbrains.compose.resources):"
    printf '  %s:%s\n' "$f" "$(echo "$bad" | cut -d: -f1 | paste -sd, -)"
    hits=1
  fi
done < <(find "$target" \( -path '*/commonMain/*' -o -path '*/commonTest/*' \) -name '*.kt' -type f -print0 2>/dev/null)

[ $hits -ne 0 ] && exit 1
echo "PASS check_no_r_class_in_common"
exit 0
