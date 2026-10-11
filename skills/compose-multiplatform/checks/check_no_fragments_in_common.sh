#!/usr/bin/env bash
# check_no_fragments_in_common.sh <kmp-src-root>
# FLAGS: androidx.fragment.* / androidx.appcompat.* / AppCompatActivity /
# FragmentActivity inside commonMain/commonTest — a Compose-only app uses
# a single-Activity architecture; Fragments exist only during a
# View->Compose migration (see the compose-migration skill).
# Rule: SKILL.md §4.
# Source: https://developer.android.com/develop/ui/compose/migrate/interoperability-apis/compose-in-views
#         ("For Compose-only apps, do not use Fragments and instead use
#          the recommended Compose-only architecture with a single
#          Activity")
# Heuristic limitation: import- and class-name-based. Full-line //
# comments are ignored.
set -uo pipefail
target="${1:?usage: check_no_fragments_in_common.sh <kmp-src-root>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=0
while IFS= read -r -d '' f; do
  bad=$(grep -nE '(^import[[:space:]]+androidx\.(fragment|appcompat)\.|\bAppCompatActivity\b|\bFragmentActivity\b)' "$f" 2>/dev/null \
    | grep -vE '(^|:)[0-9]+:[[:space:]]*//')
  if [ -n "$bad" ]; then
    [ $hits -eq 0 ] && echo "FAIL check_no_fragments_in_common: Fragment/AppCompat code in a common source set (single-Activity architecture):"
    printf '  %s:%s\n' "$f" "$(echo "$bad" | cut -d: -f1 | paste -sd, -)"
    hits=1
  fi
done < <(find "$target" \( -path '*/commonMain/*' -o -path '*/commonTest/*' \) -name '*.kt' -type f -print0 2>/dev/null)

[ $hits -ne 0 ] && exit 1
echo "PASS check_no_fragments_in_common"
exit 0
